# Testing the Improved Reminder System

## Quick Test Guide

### Setup
1. Build and run the app
2. Grant notification permissions when prompted
3. Create a goal with at least 2 reminder times (e.g., 2:00 PM and 4:00 PM)

### Test 1: Automatic Suppression
**Goal:** Verify reminder is suppressed when intake logged before scheduled time

1. Manually log an intake for the goal at 1:55 PM
2. Wait for 2:00 PM reminder
3. **Expected:** No notification appears ✅

### Test 2: Confirm Button
**Goal:** Verify Confirm button logs entry at current time

1. Don't log any intake
2. Wait for 2:00 PM reminder to fire
3. When notification appears, tap "Confirm" button
4. Open app and check history
5. **Expected:** Entry logged with timestamp when you pressed Confirm ✅

### Test 3: Cancel Button
**Goal:** Verify Cancel permanently stops this reminder

1. Don't log any intake
2. Wait for 2:00 PM reminder to fire
3. When notification appears, tap "Cancel" button
4. **Expected:** Reminder cancelled, won't repeat tomorrow ✅
5. Check pending notifications count to verify

### Test 4: Superseded Reminders
**Goal:** Verify later reminder cancels earlier one

1. Don't log any intake at 2:00 PM
2. Ignore the 2:00 PM notification
3. Wait for 4:00 PM reminder to fire
4. **Expected:** 2:00 PM reminder is automatically cancelled when 4:00 PM fires ✅
5. Only 4:00 PM notification remains active

### Test 5: Notification While App is Open
**Goal:** Verify reminders work when app is in foreground

1. Keep app open
2. Wait for scheduled reminder time
3. **Expected:** Banner notification appears at top of screen ✅
4. Can still use Confirm/Cancel buttons

### Test 6: Multiple Goals
**Goal:** Verify goals don't interfere with each other

1. Create two different goals (e.g., "Medication A" and "Medication B")
2. Schedule reminders at same time (e.g., both at 3:00 PM)
3. Log intake for only "Medication A"
4. Wait for 3:00 PM
5. **Expected:** Only "Medication B" reminder fires ✅

## Debugging Commands

### Check Pending Notifications
```swift
Task {
    let count = await IntakeReminderManager.getPendingReminderCount()
    print("Pending reminders: \(count)")
}
```

### Check if Reminder Would be Suppressed
```swift
Task {
    let store = await CommonStore.loadStore()
    let shouldSuppress = IntakeReminderManager.shouldSuppressReminder(
        for: yourGoal,
        scheduledTime: yourScheduledTime,
        store: store
    )
    print("Should suppress: \(shouldSuppress)")
}
```

### List All Pending Notifications
```swift
Task {
    let center = UNUserNotificationCenter.current()
    let requests = await center.pendingNotificationRequests()
    for request in requests {
        print("ID: \(request.identifier)")
        if let trigger = request.trigger as? UNCalendarNotificationTrigger {
            print("Next fire: \(trigger.nextTriggerDate() ?? Date())")
        }
    }
}
```

## Common Issues

### Notifications Not Appearing
- Check notification permissions in Settings
- Verify Focus mode isn't blocking notifications
- Ensure time hasn't already passed today
- Check if intake was already logged

### Confirm Button Not Logging
- Check userInfo contains all required fields (goalName, units, dosage)
- Verify store is being loaded correctly
- Check console for error messages

### Supersession Not Working
- Verify both reminders have same goalID
- Check time comparison logic
- Ensure later reminder is actually firing

## Time Testing Tips

For faster testing, schedule reminders just a few minutes ahead:

```swift
// Set reminder for 2 minutes from now
let calendar = Calendar.current
let now = Date()
let testTime = calendar.date(byAdding: .minute, value: 2, to: now)!
```

## Console Output to Watch For

**Successful suppression:**
```
Should suppress: true
```

**Supersession working:**
```
Cancelled 1 superseded reminders for goal <UUID>
```

**Confirm action:**
```
Logged intake for Medication A at 2025-01-11 14:32:15 +0000
```

**Cancel action:**
```
Cancelled reminder reminder-<UUID>-14-30 for goal <UUID>
```
