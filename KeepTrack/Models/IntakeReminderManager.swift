import Foundation
import UserNotifications

struct IntakeReminderManager {
    
    /// Schedule daily repeating reminders for a goal
    static func scheduleReminder(for goal: CommonGoal, store: CommonStore) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard granted, error == nil else { return }

            Task { @MainActor in
                let calendar = Calendar.current
                
                // First, cancel any existing reminders for this goal
                await cancelReminders(for: goal)

                for goalDate in goal.dates {
                    let content = UNMutableNotificationContent()
                    content.title = "Intake Reminder"
                    content.body = "Time to take your \(goal.name)"
                    content.sound = .default
                    content.categoryIdentifier = "INTAKE_REMINDER"
                    content.userInfo = ["goalID": goal.id.uuidString, "goalName": goal.name]

                    // Use only hour and minute for daily repeating notifications
                    var triggerDate = DateComponents()
                    triggerDate.hour = calendar.component(.hour, from: goalDate)
                    triggerDate.minute = calendar.component(.minute, from: goalDate)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                    
                    // Use a consistent identifier based on goal ID and time
                    let identifier = "reminder-\(goal.id)-\(triggerDate.hour!)-\(triggerDate.minute!)"
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                    do {
                        try await center.add(request)
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
}
