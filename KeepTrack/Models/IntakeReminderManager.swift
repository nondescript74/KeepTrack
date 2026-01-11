import Foundation
import UserNotifications

struct IntakeReminderManager {
    
    /// Setup notification categories with action buttons
    static func setupNotificationCategories() {
        let confirmAction = UNNotificationAction(
            identifier: "CONFIRM_ACTION",
            title: "Confirm",
            options: [.authenticationRequired]
        )
        
        let cancelAction = UNNotificationAction(
            identifier: "CANCEL_ACTION",
            title: "Cancel",
            options: [.destructive]
        )
        
        let category = UNNotificationCategory(
            identifier: "INTAKE_REMINDER",
            actions: [confirmAction, cancelAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    /// Schedule repeating reminders for a goal (daily, weekly, or monthly)
    static func scheduleReminder(for goal: CommonGoal, store: CommonStore) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard granted, error == nil else { return }

            Task { @MainActor in
                let calendar = Calendar.current
                
                // First, cancel any existing reminders for this goal
                await cancelReminders(for: goal)

                // Determine if this is a daily, weekly, or monthly frequency
                let isDailyFrequency = goal.frequency.contains("Day") || goal.frequency == frequency.daily.rawValue
                let isWeeklyFrequency = goal.frequency.contains("Weekly") || goal.frequency == frequency.weekly.rawValue
                let isMonthlyFrequency = goal.frequency.contains("Monthly") || goal.frequency == frequency.monthly.rawValue

                for goalDate in goal.dates {
                    let content = UNMutableNotificationContent()
                    content.title = "Intake Reminder"
                    content.body = "Time to take your \(goal.name)"
                    content.sound = .default
                    content.categoryIdentifier = "INTAKE_REMINDER"
                    content.userInfo = [
                        "goalID": goal.id.uuidString,
                        "goalName": goal.name,
                        "units": goal.units,
                        "dosage": goal.dosage,
                        "frequency": goal.frequency
                    ]

                    let trigger: UNNotificationTrigger
                    var triggerDate = DateComponents()
                    
                    if isDailyFrequency {
                        // Daily repeating: only hour and minute
                        triggerDate.hour = calendar.component(.hour, from: goalDate)
                        triggerDate.minute = calendar.component(.minute, from: goalDate)
                        trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                        
                    } else if isWeeklyFrequency {
                        // Weekly repeating: weekday, hour, and minute
                        triggerDate.weekday = calendar.component(.weekday, from: goalDate)
                        triggerDate.hour = calendar.component(.hour, from: goalDate)
                        triggerDate.minute = calendar.component(.minute, from: goalDate)
                        trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                        
                    } else if isMonthlyFrequency {
                        // Monthly repeating: day of month, hour, and minute
                        triggerDate.day = calendar.component(.day, from: goalDate)
                        triggerDate.hour = calendar.component(.hour, from: goalDate)
                        triggerDate.minute = calendar.component(.minute, from: goalDate)
                        trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                        
                    } else {
                        // Default to daily if frequency is unclear
                        triggerDate.hour = calendar.component(.hour, from: goalDate)
                        triggerDate.minute = calendar.component(.minute, from: goalDate)
                        trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                    }
                    
                    // Create identifier with appropriate components based on frequency
                    let identifier: String
                    if isWeeklyFrequency {
                        let weekday = calendar.component(.weekday, from: goalDate)
                        identifier = "reminder-\(goal.id)-w\(weekday)-\(triggerDate.hour!)-\(triggerDate.minute!)"
                    } else if isMonthlyFrequency {
                        let day = calendar.component(.day, from: goalDate)
                        identifier = "reminder-\(goal.id)-d\(day)-\(triggerDate.hour!)-\(triggerDate.minute!)"
                    } else {
                        identifier = "reminder-\(goal.id)-\(triggerDate.hour!)-\(triggerDate.minute!)"
                    }
                    
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                    do {
                        try await center.add(request)
                        print("Scheduled \(isWeeklyFrequency ? "weekly" : isMonthlyFrequency ? "monthly" : "daily") reminder: \(identifier)")
                    } catch {
                        print("Notification scheduling failed: \(error)")
                    }
                }
            }
        }
    }
    
    /// Cancel all reminders for a specific goal
    static func cancelReminders(for goal: CommonGoal) async {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        
        // Find all identifiers that start with this goal's ID
        let identifiersToCancel = pendingRequests
            .filter { $0.identifier.hasPrefix("reminder-\(goal.id)") }
            .map { $0.identifier }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
    }
    
    /// Cancel a specific reminder by identifier
    static func cancelReminder(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Cancel all reminders
    static func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Get count of pending reminders for debugging
    static func getPendingReminderCount() async -> Int {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        return pendingRequests.count
    }
    
    /// Check if a reminder should be suppressed because intake was already logged
    /// - Parameters:
    ///   - goal: The goal being checked
    ///   - scheduledTime: The scheduled trigger time for this reminder
    ///   - store: The CommonStore containing entries
    /// - Returns: True if the reminder should be suppressed (not shown)
    @MainActor static func shouldSuppressReminder(for goal: CommonGoal, scheduledTime: Date, store: CommonStore) -> Bool {
        let calendar = Calendar.current
        
        // Determine frequency type
        let isDailyFrequency = goal.frequency.contains("Day") || goal.frequency == frequency.daily.rawValue
        let isWeeklyFrequency = goal.frequency.contains("Weekly") || goal.frequency == frequency.weekly.rawValue
        let isMonthlyFrequency = goal.frequency.contains("Monthly") || goal.frequency == frequency.monthly.rawValue
        
        if isDailyFrequency {
            // For daily frequencies, check today's entries
            let todaysEntries = store.history.filter { entry in
                entry.name == goal.name && calendar.isDateInToday(entry.date)
            }
            
            // Check if any entry was logged at or before the scheduled time
            for entry in todaysEntries {
                let entryTime = calendar.dateComponents([.hour, .minute], from: entry.date)
                let scheduledComponents = calendar.dateComponents([.hour, .minute], from: scheduledTime)
                
                guard let entryHour = entryTime.hour, let entryMinute = entryTime.minute,
                      let scheduledHour = scheduledComponents.hour, let scheduledMinute = scheduledComponents.minute else {
                    continue
                }
                
                // Compare times: if entry was at or before scheduled time, suppress reminder
                if entryHour < scheduledHour || (entryHour == scheduledHour && entryMinute <= scheduledMinute) {
                    return true
                }
            }
            
        } else if isWeeklyFrequency {
            // For weekly frequencies, check entries from this week on the same weekday
            let scheduledWeekday = calendar.component(.weekday, from: scheduledTime)
            let scheduledHour = calendar.component(.hour, from: scheduledTime)
            let scheduledMinute = calendar.component(.minute, from: scheduledTime)
            
            let thisWeekEntries = store.history.filter { entry in
                guard entry.name == goal.name else { return false }
                let entryWeekday = calendar.component(.weekday, from: entry.date)
                return entryWeekday == scheduledWeekday && calendar.isDate(entry.date, equalTo: Date(), toGranularity: .weekOfYear)
            }
            
            // Check if any entry was logged at or before the scheduled time on the same weekday
            for entry in thisWeekEntries {
                let entryHour = calendar.component(.hour, from: entry.date)
                let entryMinute = calendar.component(.minute, from: entry.date)
                
                if entryHour < scheduledHour || (entryHour == scheduledHour && entryMinute <= scheduledMinute) {
                    return true
                }
            }
            
        } else if isMonthlyFrequency {
            // For monthly frequencies, check entries from this month on the same day
            let scheduledDay = calendar.component(.day, from: scheduledTime)
            let scheduledHour = calendar.component(.hour, from: scheduledTime)
            let scheduledMinute = calendar.component(.minute, from: scheduledTime)
            
            let thisMonthEntries = store.history.filter { entry in
                guard entry.name == goal.name else { return false }
                let entryDay = calendar.component(.day, from: entry.date)
                return entryDay == scheduledDay && calendar.isDate(entry.date, equalTo: Date(), toGranularity: .month)
            }
            
            // Check if any entry was logged at or before the scheduled time on the same day
            for entry in thisMonthEntries {
                let entryHour = calendar.component(.hour, from: entry.date)
                let entryMinute = calendar.component(.minute, from: entry.date)
                
                if entryHour < scheduledHour || (entryHour == scheduledHour && entryMinute <= scheduledMinute) {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Cancel any previous reminders that are superseded by a newer scheduled reminder
    /// - Parameters:
    ///   - goalID: The goal ID
    ///   - currentScheduledTime: The current reminder's scheduled time
    static func cancelSupersededReminders(for goalID: UUID, currentScheduledTime: Date) async {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        let calendar = Calendar.current
        
        // Get all reminders for this goal
        let goalReminders = pendingRequests.filter { $0.identifier.hasPrefix("reminder-\(goalID)") }
        
        let currentComponents = calendar.dateComponents([.hour, .minute], from: currentScheduledTime)
        guard let currentHour = currentComponents.hour, let currentMinute = currentComponents.minute else {
            return
        }
        
        // Find and cancel any reminders with earlier times on the same day
        var identifiersToCancel: [String] = []
        
        for request in goalReminders {
            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let triggerDate = trigger.nextTriggerDate() {
                let triggerComponents = calendar.dateComponents([.hour, .minute], from: triggerDate)
                
                if let triggerHour = triggerComponents.hour, let triggerMinute = triggerComponents.minute {
                    // If this reminder is earlier than the current one, mark it for cancellation
                    if triggerHour < currentHour || (triggerHour == currentHour && triggerMinute < currentMinute) {
                        identifiersToCancel.append(request.identifier)
                    }
                }
            }
        }
        
        if !identifiersToCancel.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
            print("Cancelled \(identifiersToCancel.count) superseded reminders for goal \(goalID)")
        }
    }
}
