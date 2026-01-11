//
//  ReminderSystemExample.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import UserNotifications

/// Example usage of the new testable reminder system
/// 
/// This file demonstrates how to use IntakeReminderManagerDI in production code
/// and how it enables comprehensive testing.

// MARK: - Production Usage Example

class GoalViewController {
    let reminderManager: IntakeReminderManagerDI
    let store: CommonStore
    
    init(store: CommonStore, reminderManager: IntakeReminderManagerDI = IntakeReminderManagerDI()) {
        self.store = store
        self.reminderManager = reminderManager
    }
    
    func setupReminders() {
        // Setup notification categories (call once at app launch)
        reminderManager.setupNotificationCategories()
    }
    
    func scheduleReminderForGoal(_ goal: CommonGoal) async {
        do {
            try await reminderManager.scheduleReminder(for: goal, store: store)
            print("Successfully scheduled reminder for \(goal.name)")
        } catch {
            print("Failed to schedule reminder: \(error)")
            // Handle error - perhaps show user alert
        }
    }
    
    func cancelReminderForGoal(_ goal: CommonGoal) async {
        await reminderManager.cancelReminders(for: goal)
        print("Cancelled reminders for \(goal.name)")
    }
    
    func checkPendingReminders() async -> Int {
        return await reminderManager.getPendingReminderCount()
    }
}

// MARK: - App Delegate Integration Example

class AppDelegate {
    let reminderManager = IntakeReminderManagerDI()
    
    func applicationDidFinishLaunching() {
        // Setup notification categories at launch
        reminderManager.setupNotificationCategories()
    }
    
    func handleNotificationResponse(_ response: UNNotificationResponse) async {
        let store: CommonStore
        do {
            store = await CommonStore.loadStore(storage: try AppGroupStorage())
        } catch {
            print("Failed to load store: \(error)")
            return
        }
        
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "CONFIRM_ACTION":
            await handleConfirmAction(userInfo: userInfo, store: store)
        case "CANCEL_ACTION":
            await handleCancelAction(userInfo: userInfo)
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification
            await handleNotificationTap(userInfo: userInfo)
        default:
            break
        }
    }
    
    private func handleConfirmAction(userInfo: [AnyHashable: Any], store: CommonStore) async {
        guard let goalName = userInfo["goalName"] as? String,
              let dosage = userInfo["dosage"] as? Double,
              let units = userInfo["units"] as? String else {
            return
        }
        
        // Log the intake
        let entry = CommonEntry(
            id: UUID(),
            date: Date.now,
            units: units,
            amount: dosage,
            name: goalName,
            goalMet: true
        )
        
        await store.addEntry(entry: entry)
        print("Logged intake for \(goalName)")
    }
    
    private func handleCancelAction(userInfo: [AnyHashable: Any]) async {
        print("User cancelled reminder")
        // Optional: reschedule for later, track cancellations, etc.
    }
    
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) async {
        // Open app to relevant screen
        print("User tapped notification")
    }
}

// MARK: - SwiftUI View Integration Example

import SwiftUI

struct GoalDetailView: View {
    let goal: CommonGoal
    @State var store: CommonStore
    let reminderManager: IntakeReminderManagerDI
    
    @State private var isSchedulingReminder = false
    @State private var pendingReminderCount = 0
    
    init(goal: CommonGoal, store: CommonStore, reminderManager: IntakeReminderManagerDI = IntakeReminderManagerDI()) {
        self.goal = goal
        self._store = State(initialValue: store)
        self.reminderManager = reminderManager
    }
    
    var body: some View {
        VStack {
            Text(goal.name)
                .font(.title)
            
            Text("Pending reminders: \(pendingReminderCount)")
                .font(.caption)
            
            Button("Schedule Reminder") {
                Task {
                    isSchedulingReminder = true
                    await scheduleReminder()
                    isSchedulingReminder = false
                }
            }
            .disabled(isSchedulingReminder)
            
            Button("Cancel Reminders") {
                Task {
                    await cancelReminders()
                }
            }
        }
        .task {
            await updatePendingCount()
        }
    }
    
    private func scheduleReminder() async {
        do {
            try await reminderManager.scheduleReminder(for: goal, store: store)
            await updatePendingCount()
        } catch {
            print("Error scheduling reminder: \(error)")
        }
    }
    
    private func cancelReminders() async {
        await reminderManager.cancelReminders(for: goal)
        await updatePendingCount()
    }
    
    private func updatePendingCount() async {
        pendingReminderCount = await reminderManager.getPendingReminderCount()
    }
}

// MARK: - Migration Guide Comments

/*
 
 MIGRATION FROM OLD TO NEW SYSTEM:
 
 OLD CODE:
 --------
 IntakeReminderManager.scheduleReminder(for: goal, store: store)
 IntakeReminderManager.cancelReminders(for: goal)
 let count = await IntakeReminderManager.getPendingReminderCount()
 
 NEW CODE:
 --------
 let manager = IntakeReminderManagerDI() // Initialize once, reuse
 try await manager.scheduleReminder(for: goal, store: store)
 await manager.cancelReminders(for: goal)
 let count = await manager.getPendingReminderCount()
 
 BENEFITS:
 --------
 1. Testable - inject MockNotificationCenter in tests
 2. Better error handling - throws instead of silent failures
 3. Async/await throughout - more modern Swift concurrency
 4. Instance methods - better for dependency injection
 5. Same functionality - all features preserved
 
 TESTING:
 --------
 let mockCenter = MockNotificationCenter()
 let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
 
 // Control authorization
 mockCenter.authorizationGranted = false
 
 // Test scheduling
 try await manager.scheduleReminder(for: goal, store: store)
 
 // Verify
 assert(mockCenter.addRequestCalls.count == expectedCount)
 assert(mockCenter.requestAuthorizationCalled)
 
 */
