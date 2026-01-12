//
//  REMINDER_TESTING_GUIDE.md
//  KeepTrack
//
//  Created on 1/11/26.
//

# Reminder System Testing Guide

## Overview

The reminder system has been refactored to support comprehensive testing through dependency injection. This guide explains the architecture and how to use it.

## Architecture

### 1. **NotificationCenterProtocol**
A protocol that abstracts `UNUserNotificationCenter` for testability.

```swift
protocol NotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func getPendingNotificationRequests() async -> [UNNotificationRequest]
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>)
}
```

### 2. **ProductionNotificationCenter**
Wraps the real `UNUserNotificationCenter` for production use.

```swift
let productionCenter = ProductionNotificationCenter()
let manager = IntakeReminderManagerDI(notificationCenter: productionCenter)
```

### 3. **MockNotificationCenter**
A mock implementation for testing that tracks all interactions.

```swift
let mockCenter = MockNotificationCenter()
mockCenter.authorizationGranted = true // Control authorization

let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)

// Test scheduling
try await manager.scheduleReminder(for: goal, store: store)

// Verify calls
assert(mockCenter.addRequestCalls.count == 1)
assert(mockCenter.requestAuthorizationCalled)
```

### 4. **IntakeReminderManagerDI**
The refactored manager that accepts a `NotificationCenterProtocol`.

```swift
// Production usage
let manager = IntakeReminderManagerDI() // Uses ProductionNotificationCenter by default

// Testing usage
let mockCenter = MockNotificationCenter()
let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
```

## Test Coverage

The test suite (`IntakeReminderManagerTests`) provides comprehensive coverage:

### Suppression Logic Tests
- ✅ Daily reminder suppression (before/after/exact time)
- ✅ Weekly reminder suppression (same/different weekday)
- ✅ Monthly reminder suppression (same/different day)
- ✅ Multiple entries handling
- ✅ Name matching validation
- ✅ Midnight boundary edge cases
- ✅ Empty store behavior
- ✅ All frequency types (twice daily, twice weekly, etc.)

### Scheduling Tests
- ✅ Daily reminder scheduling
- ✅ Weekly reminder scheduling (with weekday component)
- ✅ Monthly reminder scheduling (with day component)
- ✅ Multiple dates/times scheduling
- ✅ Authorization denial handling
- ✅ Notification content metadata
- ✅ Identifier generation

### Cancellation Tests
- ✅ Cancel reminders for specific goal
- ✅ Cancel specific reminder by identifier
- ✅ Cancel all reminders
- ✅ Re-scheduling cancels old reminders
- ✅ Get pending reminder count
- ✅ Superseded reminder cancellation

### Setup Tests
- ✅ Notification categories configuration
- ✅ Action buttons setup

## Usage Examples

### Testing Reminder Scheduling

```swift
@Test("Test my custom scheduling logic")
func testCustomScheduling() async throws {
    // Setup
    let mockCenter = MockNotificationCenter()
    let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
    let storage = InMemoryStorage()
    let store = await CommonStore.loadStore(storage: storage)
    
    // Create test goal
    let goal = makeGoal(name: "Test Med", frequency: .daily)
    
    // Execute
    try await manager.scheduleReminder(for: goal, store: store)
    
    // Verify
    #expect(mockCenter.addRequestCalls.count == 1)
    
    let request = mockCenter.addRequestCalls.first!
    #expect(request.content.title == "Intake Reminder")
    #expect(request.content.body.contains("Test Med"))
}
```

### Testing Authorization Denial

```swift
@Test("Handles authorization denial")
func testAuthorizationDenied() async throws {
    let mockCenter = MockNotificationCenter()
    mockCenter.authorizationGranted = false // Deny authorization
    
    let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
    let store = await CommonStore.loadStore(storage: InMemoryStorage())
    
    let goal = makeGoal(name: "Med", frequency: .daily)
    
    try await manager.scheduleReminder(for: goal, store: store)
    
    #expect(mockCenter.addRequestCalls.isEmpty, "Should not schedule when denied")
}
```

### Testing Cancellation

```swift
@Test("Cancels specific goal reminders")
func testCancellation() async throws {
    let mockCenter = MockNotificationCenter()
    let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
    let store = await CommonStore.loadStore(storage: InMemoryStorage())
    
    let goal = makeGoal(name: "Med", frequency: .daily)
    
    try await manager.scheduleReminder(for: goal, store: store)
    #expect(mockCenter.pendingRequests.count == 1)
    
    await manager.cancelReminders(for: goal)
    #expect(mockCenter.pendingRequests.isEmpty)
}
```

### Testing Suppression Logic

```swift
@Test("Suppresses reminder when entry logged")
func testSuppression() async throws {
    let storage = InMemoryStorage()
    let store = await CommonStore.loadStore(storage: storage)
    let manager = IntakeReminderManagerDI()
    
    let calendar = Calendar.current
    let scheduledTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: .now)!
    let entryTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: .now)!
    
    let goal = makeGoal(name: "Med", frequency: .daily, dates: [scheduledTime])
    let entry = makeEntry(name: "Med", amount: 100, date: entryTime)
    
    await store.addEntry(entry: entry, goals: goals)
    
    let shouldSuppress = await manager.shouldSuppressReminder(
        for: goal,
        scheduledTime: scheduledTime,
        store: store
    )
    
    #expect(shouldSuppress)
}
```

## Migration Guide

### For New Code

Use `IntakeReminderManagerDI` with dependency injection:

```swift
// In your app
let manager = IntakeReminderManagerDI() // Uses production center

// Setup categories
manager.setupNotificationCategories()

// Schedule reminder
try await manager.scheduleReminder(for: goal, store: store)
```

### For Existing Code

The original `IntakeReminderManager` remains unchanged for backward compatibility. Gradually migrate to the DI version:

```swift
// Old
IntakeReminderManager.scheduleReminder(for: goal, store: store)

// New
let manager = IntakeReminderManagerDI()
try await manager.scheduleReminder(for: goal, store: store)
```

## Mock Notification Center Features

The `MockNotificationCenter` tracks all interactions:

```swift
let mock = MockNotificationCenter()

// Control behavior
mock.authorizationGranted = true/false

// After operations, inspect:
mock.requestAuthorizationCalled // Bool
mock.addRequestCalls // [UNNotificationRequest]
mock.removedIdentifiers // [String]
mock.removeAllCalled // Bool
mock.pendingRequests // [UNNotificationRequest]
mock.categories // Set<UNNotificationCategory>

// Reset for next test
mock.reset()
```

## Benefits of This Approach

1. **Complete Test Isolation**: No system permissions needed
2. **Deterministic Tests**: No timing issues or async unpredictability
3. **Fast Execution**: No actual notification scheduling
4. **Comprehensive Coverage**: Test all edge cases and error paths
5. **Easy Debugging**: Inspect all interactions with the notification center
6. **Backward Compatible**: Original implementation untouched

## Running Tests

```bash
# Run all reminder tests
swift test --filter IntakeReminderManagerTests

# Run specific test
swift test --filter IntakeReminderManagerTests.scheduleDailyReminder
```

## Future Enhancements

Consider adding:
- Tests for notification response handling
- Tests for time zone edge cases
- Tests for daylight saving time transitions
- Performance tests for large numbers of reminders
- Integration tests with real UNUserNotificationCenter (optional)

## Notes

- The original `IntakeReminderManager` is preserved for compatibility
- All new code should use `IntakeReminderManagerDI`
- Tests use `InMemoryStorage` for complete isolation
- Notification identifiers follow pattern: `reminder-{goalID}-{components}`
