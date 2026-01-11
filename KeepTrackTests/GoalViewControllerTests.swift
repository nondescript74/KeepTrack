//
//  GoalViewControllerTests.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 1/11/26.
//


// MARK: - Testing Example
import Foundation
#if DEBUG
import Testing
@testable import KeepTrack
import UserNotifications

@Suite("GoalViewController Tests")
struct GoalViewControllerTests {
    
    @Test("Schedules reminder successfully")
    func scheduleReminder() async throws {
        // Setup
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        let viewController = GoalViewController(store: store, reminderManager: manager)
        
        // Create test goal
        let goal = CommonGoal(
            id: UUID(),
            name: "Test Med",
            description: "Test",
            dates: [Date.now],
            isActive: true,
            isCompleted: false,
            dosage: 100,
            units: "mg",
            frequency: frequency.daily.rawValue
        )
        
        // Execute
        await viewController.scheduleReminderForGoal(goal)
        
        // Verify
        #expect(mockCenter.addRequestCalls.count == 1)
        #expect(mockCenter.requestAuthorizationCalled)
        
        let request = mockCenter.addRequestCalls.first!
        #expect(request.content.body.contains("Test Med"))
    }
    
    @Test("Cancels reminders successfully")
    func cancelReminder() async throws {
        // Setup
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        let viewController = GoalViewController(store: store, reminderManager: manager)
        
        let goal = CommonGoal(
            id: UUID(),
            name: "Test Med",
            description: "Test",
            dates: [Date.now],
            isActive: true,
            isCompleted: false,
            dosage: 100,
            units: "mg",
            frequency: frequency.daily.rawValue
        )
        
        // Schedule first
        await viewController.scheduleReminderForGoal(goal)
        #expect(mockCenter.pendingRequests.count == 1)
        
        // Cancel
        await viewController.cancelReminderForGoal(goal)
        #expect(mockCenter.pendingRequests.isEmpty)
    }
    
    @Test("Checks pending reminder count")
    func checkPendingCount() async throws {
        // Setup
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        let viewController = GoalViewController(store: store, reminderManager: manager)
        
        // Initially 0
        let initialCount = await viewController.checkPendingReminders()
        #expect(initialCount == 0)
        
        // Schedule some reminders
        let goal1 = CommonGoal(
            id: UUID(),
            name: "Med 1",
            description: "Test",
            dates: [Date.now],
            isActive: true,
            isCompleted: false,
            dosage: 100,
            units: "mg",
            frequency: frequency.daily.rawValue
        )
        
        let goal2 = CommonGoal(
            id: UUID(),
            name: "Med 2",
            description: "Test",
            dates: [Date.now],
            isActive: true,
            isCompleted: false,
            dosage: 200,
            units: "mg",
            frequency: frequency.daily.rawValue
        )
        
        await viewController.scheduleReminderForGoal(goal1)
        await viewController.scheduleReminderForGoal(goal2)
        
        let finalCount = await viewController.checkPendingReminders()
        #expect(finalCount == 2)
    }
}
#endif
