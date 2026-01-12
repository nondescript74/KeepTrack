//
//  IntakeReminderManager+ManualEntry.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import Foundation
import UserNotifications

extension IntakeReminderManager {
    /// Handles notification cancellation when a user manually logs an intake
    ///
    /// This method checks if any pending reminders for the given goal should be cancelled
    /// based on the logged entry. It reuses the existing `shouldSuppressReminder` logic
    /// to determine which reminders are no longer needed.
    ///
    /// - Parameters:
    ///   - entry: The entry that was just logged
    ///   - goal: The goal associated with this entry
    ///   - store: The CommonStore containing entry history
    ///
    /// - Note: This should be called after adding an entry to the store
    @MainActor
    static func handleManualIntakeLogged(
        entry: CommonEntry,
        goal: CommonGoal,
        store: CommonStore
    ) async {
        // For each scheduled time in the goal, check if we should cancel its reminder
        for scheduledDate in goal.dates {
            let shouldCancel = shouldSuppressReminder(
                for: goal,
                scheduledTime: scheduledDate,
                store: store
            )
            
            if shouldCancel {
                // Build the notification identifier and cancel it
                let identifier = makeIdentifier(for: goal.id, scheduledTime: scheduledDate, goalFrequency: goal.frequency)
                cancelReminder(byIdentifier: identifier)
                
                #if DEBUG
                print("📱 Cancelled reminder: \(identifier) (entry logged manually)")
                #endif
            }
        }
    }
    
    /// Creates a notification identifier for a specific goal and scheduled time
    ///
    /// - Parameters:
    ///   - goalID: The UUID of the goal
    ///   - scheduledTime: The scheduled time for this reminder
    ///   - goalFrequency: The frequency string from the goal
    /// - Returns: A string identifier matching the format used in scheduleReminder
    static func makeIdentifier(for goalID: UUID, scheduledTime: Date, goalFrequency: String) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: scheduledTime)
        let minute = calendar.component(.minute, from: scheduledTime)
        
        let isWeeklyFrequency = goalFrequency.contains("Weekly") || goalFrequency == frequency.weekly.rawValue
        let isMonthlyFrequency = goalFrequency.contains("Monthly") || goalFrequency == frequency.monthly.rawValue
        
        if isWeeklyFrequency {
            let weekday = calendar.component(.weekday, from: scheduledTime)
            return "reminder-\(goalID)-w\(weekday)-\(hour)-\(minute)"
        } else if isMonthlyFrequency {
            let day = calendar.component(.day, from: scheduledTime)
            return "reminder-\(goalID)-d\(day)-\(hour)-\(minute)"
        } else {
            return "reminder-\(goalID)-\(hour)-\(minute)"
        }
    }
    
    /// Cancels a specific reminder by its identifier
    ///
    /// - Parameter identifier: The notification identifier to cancel
    static func cancelReminder(byIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
