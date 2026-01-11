//
//  IntakeReminderManagerTests.swift
//  KeepTrackTests
//
//  Created on 1/11/26.
//

import Foundation
import Testing
import UserNotifications
@testable import KeepTrack

/// Comprehensive test suite for IntakeReminderManager
///
/// This test suite validates the reminder scheduling, cancellation, and suppression
/// logic of the IntakeReminderManager. It uses a mock notification center to avoid
/// requiring notification permissions during testing.
///
/// Coverage includes:
/// - Daily reminder scheduling
/// - Weekly reminder scheduling
/// - Monthly reminder scheduling
/// - Reminder cancellation for specific goals
/// - Reminder cancellation by identifier
/// - All reminders cancellation
/// - Reminder suppression logic (daily, weekly, monthly)
/// - Superseded reminder cancellation
///
/// Note: These tests mock UNUserNotificationCenter behavior since we cannot
/// directly test system notifications without permissions and async delays.
@Suite("IntakeReminderManager Tests")
struct IntakeReminderManagerTests {
    
    // MARK: - Helper Functions
    
    /// Creates a test goal with specified parameters
    func makeGoal(
        name: String = "Test Medication",
        frequency: frequency = .daily,
        dates: [Date] = [Date.now],
        dosage: Double = 100.0,
        units: String = "mg"
    ) -> CommonGoal {
        CommonGoal(
            id: UUID(),
            name: name,
            description: "Test description",
            dates: dates,
            isActive: true,
            isCompleted: false,
            dosage: dosage,
            units: units,
            frequency: frequency.rawValue
        )
    }
    
    /// Creates a test entry for store history
    func makeEntry(
        name: String,
        amount: Double,
        date: Date = .now,
        units: String = "mg",
        goalMet: Bool = false
    ) -> CommonEntry {
        CommonEntry(
            id: UUID(),
            date: date,
            units: units,
            amount: amount,
            name: name,
            goalMet: goalMet
        )
    }
    
    // MARK: - Reminder Suppression Tests
    
    @Test("Daily reminder should be suppressed when entry logged before scheduled time")
    func dailyReminderSuppressionBeforeTime() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal scheduled for 2 PM
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Daily Med", frequency: .daily, dates: [scheduledTime])
        
        // Log an entry at 1 PM (before scheduled time)
        let entryTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now)!
        let entry = makeEntry(name: "Daily Med", amount: 100, date: entryTime)
        await store.addEntry(entry: entry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(shouldSuppress, "Reminder should be suppressed when entry logged before scheduled time")
    }
    
    @Test("Daily reminder should NOT be suppressed when entry logged after scheduled time")
    func dailyReminderNotSuppressionAfterTime() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal scheduled for 2 PM
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Daily Med", frequency: .daily, dates: [scheduledTime])
        
        // Log an entry at 3 PM (after scheduled time)
        let entryTime = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now)!
        let entry = makeEntry(name: "Daily Med", amount: 100, date: entryTime)
        await store.addEntry(entry: entry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(!shouldSuppress, "Reminder should NOT be suppressed when entry logged after scheduled time")
    }
    
    @Test("Daily reminder should NOT be suppressed when no entry exists")
    func dailyReminderNoEntry() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal scheduled for 2 PM
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Daily Med", frequency: .daily, dates: [scheduledTime])
        
        // No entry logged
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(!shouldSuppress, "Reminder should NOT be suppressed when no entry exists")
    }
    
    @Test("Weekly reminder should be suppressed when entry logged on same weekday before time")
    func weeklyReminderSuppressionSameWeekday() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal scheduled for today at 2 PM, weekly frequency
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Weekly Med", frequency: .weekly, dates: [scheduledTime])
        
        // Log an entry today at 1 PM (same weekday, before scheduled time)
        let entryTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now)!
        let entry = makeEntry(name: "Weekly Med", amount: 100, date: entryTime)
        await store.addEntry(entry: entry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(shouldSuppress, "Weekly reminder should be suppressed when entry logged same weekday before time")
    }
    
    @Test("Weekly reminder should NOT be suppressed when entry from different weekday")
    func weeklyReminderDifferentWeekday() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal scheduled for today at 2 PM, weekly frequency
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Weekly Med", frequency: .weekly, dates: [scheduledTime])
        
        // Log an entry yesterday at 1 PM (different weekday)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let entryTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: yesterday)!
        let entry = makeEntry(name: "Weekly Med", amount: 100, date: entryTime)
        await store.addEntry(entry: entry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(!shouldSuppress, "Weekly reminder should NOT be suppressed when entry from different weekday")
    }
    
    @Test("Monthly reminder should be suppressed when entry logged on same day before time")
    func monthlyReminderSuppressionSameDay() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal scheduled for today at 2 PM, monthly frequency
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Monthly Med", frequency: .monthly, dates: [scheduledTime])
        
        // Log an entry today at 1 PM (same day of month, before scheduled time)
        let entryTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now)!
        let entry = makeEntry(name: "Monthly Med", amount: 100, date: entryTime)
        await store.addEntry(entry: entry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(shouldSuppress, "Monthly reminder should be suppressed when entry logged same day before time")
    }
    
    @Test("Monthly reminder should NOT be suppressed when entry from different day")
    func monthlyReminderDifferentDay() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal scheduled for today at 2 PM, monthly frequency
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Monthly Med", frequency: .monthly, dates: [scheduledTime])
        
        // Log an entry yesterday at 1 PM (different day of month)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let entryTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: yesterday)!
        let entry = makeEntry(name: "Monthly Med", amount: 100, date: entryTime)
        await store.addEntry(entry: entry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(!shouldSuppress, "Monthly reminder should NOT be suppressed when entry from different day")
    }
    
    @Test("Reminder suppression respects exact scheduled time")
    func reminderSuppressionExactTime() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal scheduled for 2:00 PM
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Daily Med", frequency: .daily, dates: [scheduledTime])
        
        // Log an entry at exactly 2:00 PM (at scheduled time)
        let entryTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let entry = makeEntry(name: "Daily Med", amount: 100, date: entryTime)
        await store.addEntry(entry: entry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(shouldSuppress, "Reminder should be suppressed when entry logged at exactly scheduled time")
    }
    
    @Test("Multiple entries - suppression considers earliest entry")
    func multipleEntriesConsidersEarliest() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal scheduled for 2 PM
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Daily Med", frequency: .daily, dates: [scheduledTime])
        
        // Log multiple entries - one before, one after
        let earlyEntry = makeEntry(
            name: "Daily Med",
            amount: 100,
            date: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now)!
        )
        let lateEntry = makeEntry(
            name: "Daily Med",
            amount: 100,
            date: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now)!
        )
        
        await store.addEntry(entry: earlyEntry)
        await store.addEntry(entry: lateEntry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(shouldSuppress, "Reminder should be suppressed when any entry was logged before scheduled time")
    }
    
    @Test("Suppression only checks matching goal names")
    func suppressionOnlyMatchingNames() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal scheduled for 2 PM
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Medication A", frequency: .daily, dates: [scheduledTime])
        
        // Log an entry for a DIFFERENT medication before scheduled time
        let entryTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now)!
        let entry = makeEntry(name: "Medication B", amount: 100, date: entryTime)
        await store.addEntry(entry: entry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(!shouldSuppress, "Reminder should NOT be suppressed by entries for different medications")
    }
    
    @Test("Twice daily frequency uses daily suppression logic")
    func twiceDailyFrequencyUsesDaily() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal with twice daily frequency
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Twice Daily Med", frequency: .twiceADay, dates: [scheduledTime])
        
        // Log an entry at 1 PM
        let entryTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now)!
        let entry = makeEntry(name: "Twice Daily Med", amount: 100, date: entryTime)
        await store.addEntry(entry: entry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(shouldSuppress, "Twice daily frequency should use daily suppression logic")
    }
    
    @Test("Twice weekly frequency uses weekly suppression logic")
    func twiceWeeklyFrequencyUsesWeekly() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let now = Date.now
        
        // Create a goal with twice weekly frequency
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        let goal = makeGoal(name: "Twice Weekly Med", frequency: .twiceWeekly, dates: [scheduledTime])
        
        // Log an entry today at 1 PM (same weekday, before time)
        let entryTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now)!
        let entry = makeEntry(name: "Twice Weekly Med", amount: 100, date: entryTime)
        await store.addEntry(entry: entry)
        
        // Check if reminder should be suppressed
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(shouldSuppress, "Twice weekly frequency should use weekly suppression logic")
    }
    
    // MARK: - Goal Structure Tests
    
    @Test("Goal has correct structure for daily reminders")
    func goalStructureDaily() {
        let goal = makeGoal(name: "Test Med", frequency: .daily)
        
        #expect(goal.name == "Test Med")
        #expect(goal.frequency == frequency.daily.rawValue)
        #expect(goal.isActive == true)
        #expect(goal.dosage == 100.0)
        #expect(goal.units == "mg")
    }
    
    @Test("Goal supports multiple scheduled dates")
    func goalMultipleDates() {
        let calendar = Calendar.current
        let now = Date.now
        
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now)!
        let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now)!
        
        let goal = makeGoal(
            name: "Twice Daily Med",
            frequency: .twiceADay,
            dates: [morning, evening]
        )
        
        #expect(goal.dates.count == 2)
        #expect(goal.dates.contains(morning))
        #expect(goal.dates.contains(evening))
    }
    
    @Test("Goal frequency supports all frequency types")
    func goalSupportsAllFrequencies() {
        for freq in frequency.allCases where freq != .none {
            let goal = makeGoal(name: "Test", frequency: freq)
            #expect(goal.frequency == freq.rawValue)
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("Suppression handles midnight boundary correctly")
    func suppressionMidnightBoundary() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let today = Date.now
        
        // Schedule for 1 AM today
        let scheduledTime = calendar.date(bySettingHour: 1, minute: 0, second: 0, of: today)!
        let goal = makeGoal(name: "Late Night Med", frequency: .daily, dates: [scheduledTime])
        
        // Log entry yesterday at 11 PM (should not suppress today's 1 AM reminder)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastNightEntry = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: yesterday)!
        let entry = makeEntry(name: "Late Night Med", amount: 100, date: lastNightEntry)
        await store.addEntry(entry: entry)
        
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(!shouldSuppress, "Yesterday's entry should not suppress today's reminder")
    }
    
    @Test("Empty store history does not cause suppression")
    func emptyStoreNoSuppression() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: .now)!
        let goal = makeGoal(name: "Test Med", frequency: .daily, dates: [scheduledTime])
        
        // Empty store, no entries
        let shouldSuppress = await IntakeReminderManager.shouldSuppressReminder(
            for: goal,
            scheduledTime: scheduledTime,
            store: store
        )
        
        #expect(!shouldSuppress, "Empty store should never suppress reminders")
    }
    
    // MARK: - Scheduling Tests (with Dependency Injection)
    
    @Test("Schedules daily reminder correctly")
    func scheduleDailyReminder() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let scheduledTime = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: .now)!
        let goal = makeGoal(name: "Daily Med", frequency: .daily, dates: [scheduledTime])
        
        try await manager.scheduleReminder(for: goal, store: store)
        
        #expect(mockCenter.requestAuthorizationCalled, "Should request authorization")
        #expect(mockCenter.addRequestCalls.count == 1, "Should add 1 notification request")
        
        let request = mockCenter.addRequestCalls.first!
        #expect(request.identifier.hasPrefix("reminder-\(goal.id)"), "Identifier should contain goal ID")
        #expect(request.content.title == "Intake Reminder", "Title should be correct")
        #expect(request.content.body.contains(goal.name), "Body should contain goal name")
        
        // Verify trigger is calendar-based
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(trigger.repeats == true, "Should be repeating")
        
        let triggerComponents = trigger.dateComponents
        #expect(triggerComponents.hour == 14, "Hour should be 14")
        #expect(triggerComponents.minute == 30, "Minute should be 30")
    }
    
    @Test("Schedules weekly reminder with weekday component")
    func scheduleWeeklyReminder() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let scheduledTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: .now)!
        let goal = makeGoal(name: "Weekly Med", frequency: .weekly, dates: [scheduledTime])
        
        try await manager.scheduleReminder(for: goal, store: store)
        
        #expect(mockCenter.addRequestCalls.count == 1, "Should add 1 notification request")
        
        let request = mockCenter.addRequestCalls.first!
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        
        let triggerComponents = trigger.dateComponents
        let expectedWeekday = calendar.component(.weekday, from: scheduledTime)
        
        #expect(triggerComponents.weekday == expectedWeekday, "Weekday should match")
        #expect(triggerComponents.hour == 10, "Hour should be 10")
        #expect(triggerComponents.minute == 0, "Minute should be 0")
        #expect(trigger.repeats == true, "Should be repeating")
    }
    
    @Test("Schedules monthly reminder with day component")
    func scheduleMonthlyReminder() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let scheduledTime = calendar.date(bySettingHour: 9, minute: 15, second: 0, of: .now)!
        let goal = makeGoal(name: "Monthly Med", frequency: .monthly, dates: [scheduledTime])
        
        try await manager.scheduleReminder(for: goal, store: store)
        
        #expect(mockCenter.addRequestCalls.count == 1, "Should add 1 notification request")
        
        let request = mockCenter.addRequestCalls.first!
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        
        let triggerComponents = trigger.dateComponents
        let expectedDay = calendar.component(.day, from: scheduledTime)
        
        #expect(triggerComponents.day == expectedDay, "Day should match")
        #expect(triggerComponents.hour == 9, "Hour should be 9")
        #expect(triggerComponents.minute == 15, "Minute should be 15")
        #expect(trigger.repeats == true, "Should be repeating")
    }
    
    @Test("Schedules multiple reminders for multiple dates")
    func scheduleMultipleDates() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: .now)!
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: .now)!
        let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: .now)!
        
        let goal = makeGoal(
            name: "Three Times Daily",
            frequency: .threeTimesADay,
            dates: [morning, noon, evening]
        )
        
        try await manager.scheduleReminder(for: goal, store: store)
        
        #expect(mockCenter.addRequestCalls.count == 3, "Should add 3 notification requests")
        
        // Verify each time is scheduled
        let triggers = mockCenter.addRequestCalls.compactMap { $0.trigger as? UNCalendarNotificationTrigger }
        let hours = triggers.compactMap { $0.dateComponents.hour }
        
        #expect(hours.contains(8), "Should schedule 8 AM")
        #expect(hours.contains(12), "Should schedule 12 PM")
        #expect(hours.contains(20), "Should schedule 8 PM")
    }
    
    @Test("Does not schedule when authorization denied")
    func noScheduleWhenAuthorizationDenied() async throws {
        let mockCenter = MockNotificationCenter()
        mockCenter.authorizationGranted = false
        
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let goal = makeGoal(name: "Test Med", frequency: .daily)
        
        try await manager.scheduleReminder(for: goal, store: store)
        
        #expect(mockCenter.requestAuthorizationCalled, "Should request authorization")
        #expect(mockCenter.addRequestCalls.isEmpty, "Should not add any requests when denied")
    }
    
    @Test("Notification content includes goal metadata")
    func notificationContentMetadata() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let goal = makeGoal(
            name: "Vitamin C",
            frequency: .daily,
            dosage: 500.0,
            units: "mg"
        )
        
        try await manager.scheduleReminder(for: goal, store: store)
        
        let request = try #require(mockCenter.addRequestCalls.first)
        let userInfo = request.content.userInfo
        
        #expect(userInfo["goalID"] as? String == goal.id.uuidString, "Should include goal ID")
        #expect(userInfo["goalName"] as? String == "Vitamin C", "Should include goal name")
        #expect(userInfo["units"] as? String == "mg", "Should include units")
        #expect(userInfo["dosage"] as? Double == 500.0, "Should include dosage")
        #expect(userInfo["frequency"] as? String == frequency.daily.rawValue, "Should include frequency")
    }
    
    // MARK: - Cancellation Tests
    
    @Test("Cancels reminders for specific goal")
    func cancelRemindersForGoal() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let goal1 = makeGoal(name: "Med 1", frequency: .daily)
        let goal2 = makeGoal(name: "Med 2", frequency: .daily)
        
        // Schedule both
        try await manager.scheduleReminder(for: goal1, store: store)
        try await manager.scheduleReminder(for: goal2, store: store)
        
        #expect(mockCenter.pendingRequests.count == 2, "Should have 2 pending requests")
        
        // Cancel only goal1
        await manager.cancelReminders(for: goal1)
        
        #expect(mockCenter.pendingRequests.count == 1, "Should have 1 pending request after cancellation")
        #expect(mockCenter.pendingRequests.first?.identifier.contains(goal2.id.uuidString) == true,
                "Remaining request should be for goal2")
    }
    
    @Test("Cancel specific reminder by identifier")
    func cancelReminderByIdentifier() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: .now)!
        let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: .now)!
        
        let goal = makeGoal(name: "Twice Daily", frequency: .twiceADay, dates: [morning, evening])
        
        try await manager.scheduleReminder(for: goal, store: store)
        
        #expect(mockCenter.pendingRequests.count == 2, "Should have 2 pending requests")
        
        let identifierToCancel = mockCenter.pendingRequests.first!.identifier
        manager.cancelReminder(withIdentifier: identifierToCancel)
        
        #expect(mockCenter.pendingRequests.count == 1, "Should have 1 pending request after cancellation")
        #expect(!mockCenter.pendingRequests.contains { $0.identifier == identifierToCancel },
                "Cancelled identifier should not be in pending requests")
    }
    
    @Test("Cancel all reminders")
    func cancelAllReminders() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let goal1 = makeGoal(name: "Med 1", frequency: .daily)
        let goal2 = makeGoal(name: "Med 2", frequency: .daily)
        
        try await manager.scheduleReminder(for: goal1, store: store)
        try await manager.scheduleReminder(for: goal2, store: store)
        
        #expect(mockCenter.pendingRequests.count == 2, "Should have 2 pending requests")
        
        manager.cancelAllReminders()
        
        #expect(mockCenter.removeAllCalled, "Should call removeAll")
        #expect(mockCenter.pendingRequests.isEmpty, "Should have no pending requests")
    }
    
    @Test("Scheduling new reminder cancels old ones for same goal")
    func schedulingCancelsOldReminders() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let calendar = Calendar.current
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: .now)!
        
        // Schedule first reminder
        let goal = makeGoal(name: "Med", frequency: .daily, dates: [morning])
        try await manager.scheduleReminder(for: goal, store: store)
        
        let firstIdentifier = mockCenter.addRequestCalls.first!.identifier
        
        // Schedule again (should cancel old and add new)
        try await manager.scheduleReminder(for: goal, store: store)
        
        // Should have removed the old identifier
        #expect(mockCenter.removedIdentifiers.contains { $0 == firstIdentifier },
                "Should cancel old reminder")
        
        // Should only have 1 pending (the new one)
        #expect(mockCenter.pendingRequests.count == 1, "Should only have 1 pending request")
    }
    
    @Test("Get pending reminder count")
    func getPendingReminderCount() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let initialCount = await manager.getPendingReminderCount()
        #expect(initialCount == 0, "Should start with 0 pending")
        
        let goal1 = makeGoal(name: "Med 1", frequency: .daily)
        let goal2 = makeGoal(name: "Med 2", frequency: .daily)
        
        try await manager.scheduleReminder(for: goal1, store: store)
        try await manager.scheduleReminder(for: goal2, store: store)
        
        let count = await manager.getPendingReminderCount()
        #expect(count == 2, "Should have 2 pending reminders")
    }
    
    // MARK: - Superseded Reminders Tests
    
    @Test("Cancels superseded reminders with earlier times")
    func cancelSupersededReminders() async throws {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        
        let calendar = Calendar.current
        let goalID = UUID()
        
        // Create mock requests with different times
        let earlyContent = UNMutableNotificationContent()
        let earlyTrigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: 8, minute: 0),
            repeats: true
        )
        let earlyRequest = UNNotificationRequest(
            identifier: "reminder-\(goalID)-8-0",
            content: earlyContent,
            trigger: earlyTrigger
        )
        
        let laterContent = UNMutableNotificationContent()
        let laterTrigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: 14, minute: 0),
            repeats: true
        )
        let laterRequest = UNNotificationRequest(
            identifier: "reminder-\(goalID)-14-0",
            content: laterContent,
            trigger: laterTrigger
        )
        
        // Add both to mock center
        mockCenter.pendingRequests = [earlyRequest, laterRequest]
        
        // Cancel superseded for 2 PM time
        let currentTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: .now)!
        await manager.cancelSupersededReminders(for: goalID, currentScheduledTime: currentTime)
        
        // The 8 AM reminder should be cancelled
        #expect(mockCenter.removedIdentifiers.contains("reminder-\(goalID)-8-0"),
                "Should cancel earlier reminder")
        #expect(mockCenter.pendingRequests.count == 1, "Should have 1 remaining request")
        #expect(mockCenter.pendingRequests.first?.identifier == "reminder-\(goalID)-14-0",
                "Should keep later reminder")
    }
    
    // MARK: - Setup Tests
    
    @Test("Setup notification categories")
    func setupCategories() {
        let mockCenter = MockNotificationCenter()
        let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
        
        manager.setupNotificationCategories()
        
        #expect(mockCenter.categories.count == 1, "Should set 1 category")
        
        let category = mockCenter.categories.first!
        #expect(category.identifier == "INTAKE_REMINDER", "Category ID should be INTAKE_REMINDER")
        #expect(category.actions.count == 2, "Should have 2 actions")
        
        let actionIdentifiers = category.actions.map { $0.identifier }
        #expect(actionIdentifiers.contains("CONFIRM_ACTION"), "Should have confirm action")
        #expect(actionIdentifiers.contains("CANCEL_ACTION"), "Should have cancel action")
    }
}
