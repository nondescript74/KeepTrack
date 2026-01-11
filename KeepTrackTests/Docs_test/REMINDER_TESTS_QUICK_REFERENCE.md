//
//  REMINDER_TESTS_QUICK_REFERENCE.md
//  KeepTrack
//
//  Created on 1/11/26.
//

# Reminder Tests Quick Reference

## Test Suite Overview

**File**: `IntakeReminderManagerTests.swift`  
**Total Tests**: 35  
**Framework**: Swift Testing (with `@Test` and `@Suite`)

## Test Categories

### 1️⃣ Suppression Logic Tests (13 tests)

| Test | What It Validates |
|------|-------------------|
| `dailyReminderSuppressionBeforeTime` | Daily reminder suppressed when logged before time |
| `dailyReminderNotSuppressionAfterTime` | Daily reminder NOT suppressed when logged after time |
| `dailyReminderNoEntry` | Daily reminder NOT suppressed with no entry |
| `weeklyReminderSuppressionSameWeekday` | Weekly reminder suppressed on same weekday before time |
| `weeklyReminderDifferentWeekday` | Weekly reminder NOT suppressed on different weekday |
| `monthlyReminderSuppressionSameDay` | Monthly reminder suppressed on same day before time |
| `monthlyReminderDifferentDay` | Monthly reminder NOT suppressed on different day |
| `reminderSuppressionExactTime` | Reminder suppressed when logged at exact scheduled time |
| `multipleEntriesConsidersEarliest` | With multiple entries, earliest determines suppression |
| `suppressionOnlyMatchingNames` | Only entries matching goal name affect suppression |
| `twiceDailyFrequencyUsesDaily` | Twice daily frequency uses daily logic |
| `twiceWeeklyFrequencyUsesWeekly` | Twice weekly frequency uses weekly logic |
| `suppressionMidnightBoundary` | Correctly handles midnight day boundary |
| `emptyStoreNoSuppression` | Empty store never suppresses reminders |

### 2️⃣ Scheduling Tests (7 tests)

| Test | What It Validates |
|------|-------------------|
| `scheduleDailyReminder` | Daily reminder scheduled with hour/minute only |
| `scheduleWeeklyReminder` | Weekly reminder includes weekday component |
| `scheduleMonthlyReminder` | Monthly reminder includes day component |
| `scheduleMultipleDates` | Schedules notification for each date in goal |
| `noScheduleWhenAuthorizationDenied` | No scheduling when user denies permission |
| `notificationContentMetadata` | Notification includes all goal metadata |

### 3️⃣ Cancellation Tests (5 tests)

| Test | What It Validates |
|------|-------------------|
| `cancelRemindersForGoal` | Cancels all reminders for specific goal only |
| `cancelReminderByIdentifier` | Cancels single reminder by identifier |
| `cancelAllReminders` | Cancels all pending reminders |
| `schedulingCancelsOldReminders` | Re-scheduling automatically cancels old ones |
| `getPendingReminderCount` | Correctly counts pending reminders |

### 4️⃣ Advanced Tests (3 tests)

| Test | What It Validates |
|------|-------------------|
| `cancelSupersededReminders` | Cancels earlier reminders when logging intake |
| `setupCategories` | Notification categories configured correctly |

### 5️⃣ Goal Structure Tests (3 tests)

| Test | What It Validates |
|------|-------------------|
| `goalStructureDaily` | Goal has correct properties for daily reminders |
| `goalMultipleDates` | Goal supports multiple scheduled dates |
| `goalSupportsAllFrequencies` | All frequency types are supported |

## Quick Usage

### Run All Tests
```bash
swift test --filter IntakeReminderManagerTests
```

### Run Specific Category
```bash
# Suppression tests
swift test --filter IntakeReminderManagerTests.dailyReminder

# Scheduling tests
swift test --filter IntakeReminderManagerTests.schedule

# Cancellation tests
swift test --filter IntakeReminderManagerTests.cancel
```

### Run Single Test
```bash
swift test --filter IntakeReminderManagerTests.scheduleDailyReminder
```

## Test Pattern

All tests follow this pattern:

```swift
@Test("Description of what is being tested")
func testName() async throws {
    // 1. Setup - Create mock, manager, store, and test data
    let mockCenter = MockNotificationCenter()
    let manager = IntakeReminderManagerDI(notificationCenter: mockCenter)
    let storage = InMemoryStorage()
    let store = await CommonStore.loadStore(storage: storage)
    
    // 2. Execute - Perform the operation
    try await manager.scheduleReminder(for: goal, store: store)
    
    // 3. Verify - Assert expected outcomes
    #expect(mockCenter.addRequestCalls.count == 1)
    #expect(mockCenter.requestAuthorizationCalled)
}
```

## Helper Functions

### `makeGoal()`
Creates test goals with sensible defaults:

```swift
let goal = makeGoal(
    name: "Test Med",
    frequency: .daily,
    dates: [Date.now],
    dosage: 100.0,
    units: "mg"
)
```

### `makeEntry()`
Creates test entries for store history:

```swift
let entry = makeEntry(
    name: "Test Med",
    amount: 100,
    date: Date.now,
    units: "mg",
    goalMet: true
)
```

## Mock Inspection

After operations, inspect the mock to verify behavior:

```swift
// Authorization
mockCenter.requestAuthorizationCalled // Bool

// Scheduled notifications
mockCenter.addRequestCalls // [UNNotificationRequest]
mockCenter.pendingRequests // [UNNotificationRequest]

// Cancellations
mockCenter.removedIdentifiers // [String]
mockCenter.removeAllCalled // Bool

// Categories
mockCenter.categories // Set<UNNotificationCategory>

// Control behavior
mockCenter.authorizationGranted = false
```

## Common Assertions

```swift
// Verify authorization requested
#expect(mockCenter.requestAuthorizationCalled)

// Verify notification count
#expect(mockCenter.addRequestCalls.count == expectedCount)

// Verify notification content
let request = mockCenter.addRequestCalls.first!
#expect(request.content.title == "Intake Reminder")
#expect(request.content.body.contains(goalName))

// Verify trigger type
let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
#expect(trigger.repeats == true)

// Verify trigger time
let components = trigger.dateComponents
#expect(components.hour == 14)
#expect(components.minute == 30)

// Verify cancellation
#expect(mockCenter.pendingRequests.isEmpty)
#expect(mockCenter.removedIdentifiers.contains(identifier))

// Verify suppression
let shouldSuppress = await manager.shouldSuppressReminder(...)
#expect(shouldSuppress)
```

## Coverage Areas

✅ Daily, weekly, monthly frequencies  
✅ Single and multiple scheduled times  
✅ Authorization granted and denied  
✅ Entry logging before/after/at scheduled time  
✅ Same/different day boundaries  
✅ Name matching logic  
✅ Identifier generation  
✅ Metadata in notifications  
✅ Cancellation strategies  
✅ Empty store edge case  
✅ Midnight boundary  
✅ All frequency variants  

## Files Involved

| File | Purpose |
|------|---------|
| `IntakeReminderManagerTests.swift` | Test suite (35 tests) |
| `NotificationCenterProtocol.swift` | Mock infrastructure |
| `IntakeReminderManagerRefactored.swift` | Testable implementation |
| `IntakeReminderManager.swift` | Original (preserved) |
| `REMINDER_TESTING_GUIDE.md` | Full documentation |
| `ReminderSystemExample.swift` | Usage examples |

## Next Steps

1. Run the tests: `swift test --filter IntakeReminderManagerTests`
2. Check coverage in Xcode
3. Review any failures
4. Migrate production code to use `IntakeReminderManagerDI`
5. Add integration tests if needed

## Troubleshooting

**Problem**: Tests fail with "Cannot find type 'MockNotificationCenter'"  
**Solution**: Ensure `NotificationCenterProtocol.swift` is in test target

**Problem**: Tests timeout  
**Solution**: Check for infinite loops or missing `await` keywords

**Problem**: Flaky tests  
**Solution**: Use `InMemoryStorage` not file system storage

**Problem**: Can't schedule in tests  
**Solution**: Use `IntakeReminderManagerDI` with `MockNotificationCenter`

## Best Practices

1. ✅ Always use `InMemoryStorage` in tests
2. ✅ Reset mock between tests (automatic with new instances)
3. ✅ Use descriptive test names
4. ✅ Test one thing per test
5. ✅ Use `#expect` for assertions
6. ✅ Use `try #require` for unwrapping
7. ✅ Mark async tests with `async throws`
8. ✅ Group related tests with comments
