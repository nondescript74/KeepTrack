//
//  IntakeReminderManagerRefactored.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import UserNotifications

/// Refactored IntakeReminderManager with dependency injection support
///
/// This version accepts a NotificationCenterProtocol for complete testability.
/// Use this in new code. The original IntakeReminderManager remains for compatibility.
struct IntakeReminderManagerDI {
    
    let notificationCenter: NotificationCenterProtocol
    
    /// Initialize with a custom notification center (for testing) or production center
    init(notificationCenter: NotificationCenterProtocol = ProductionNotificationCenter()) {
        self.notificationCenter = notificationCenter
    }
    
    /// Setup notification categories with action buttons
    func setupNotificationCategories() {
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
        
        notificationCenter.setNotificationCategories([category])
    }
    
    /// Schedule repeating reminders for a goal (daily, weekly, or monthly)
    func scheduleReminder(for goal: CommonGoal, store: CommonStore) async throws {
        let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
        guard granted else { return }
        
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
            try await notificationCenter.add(request)
        }
    }
    
    /// Cancel all reminders for a specific goal
    func cancelReminders(for goal: CommonGoal) async {
        let pendingRequests = await notificationCenter.getPendingNotificationRequests()
        
        // Find all identifiers that start with this goal's ID
        let identifiersToCancel = pendingRequests
            .filter { $0.identifier.hasPrefix("reminder-\(goal.id)") }
            .map { $0.identifier }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
    }
    
    /// Cancel a specific reminder by identifier
    func cancelReminder(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Cancel all reminders
    func cancelAllReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    /// Get count of pending reminders for debugging
    func getPendingReminderCount() async -> Int {
        let pendingRequests = await notificationCenter.getPendingNotificationRequests()
        return pendingRequests.count
    }
    
    /// Get all pending notification requests
    func getPendingRequests() async -> [UNNotificationRequest] {
        await notificationCenter.getPendingNotificationRequests()
    }
    
    /// Check if a reminder should be suppressed because intake was already logged
    @MainActor func shouldSuppressReminder(for goal: CommonGoal, scheduledTime: Date, store: CommonStore) -> Bool {
        IntakeReminderManager.shouldSuppressReminder(for: goal, scheduledTime: scheduledTime, store: store)
    }
    
    /// Cancel any previous reminders that are superseded by a newer scheduled reminder
    func cancelSupersededReminders(for goalID: UUID, currentScheduledTime: Date) async {
        let pendingRequests = await notificationCenter.getPendingNotificationRequests()
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
            notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
        }
    }
}
