import Foundation
import UserNotifications

struct IntakeReminderManager {
    static func scheduleReminder(for goal: CommonGoal, store: CommonStore) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard granted, error == nil else { return }

            Task { @MainActor in
                let takenToday = store.getTodaysIntake().filter { $0.name == goal.name }
                let calendar = Calendar.current

                for goalDate in goal.dates {
                    // Only schedule if no taken entry for that time (within 1 hour window)
                    let alreadyTaken = takenToday.contains { entry in
                        abs(entry.date.timeIntervalSince(goalDate)) < 60 * 60
                    }
                    if !alreadyTaken {
                        let content = UNMutableNotificationContent()
                        content.title = "Intake Reminder"
                        content.body = "Did you take your \(goal.name) by the goal time?"
                        content.sound = .default

                        let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: goalDate)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                        let request = UNNotificationRequest(identifier: "reminder-\(goal.id)-\(goalDate.timeIntervalSince1970)", content: content, trigger: trigger)

                        do {
                            try await center.add(request)
                        } catch {
                            print("Notification scheduling failed: \(error)")
                        }
                    }
                }
            }
        }
    }
}
