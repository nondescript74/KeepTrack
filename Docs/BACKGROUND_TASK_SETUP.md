# Background Task Setup Guide

## Overview

This guide explains how to set up background processing for automatic reminder management in KeepTrack. The background task system ensures that:

1. **Reminders are cancelled** when you log an intake
2. **Next reminders are scheduled** automatically based on frequency (daily, weekly, monthly)
3. **Processing happens in the background** even when the app isn't running

## How It Works

```
User logs intake (e.g., at 7:30 AM for 8:00 AM daily medication)
    ↓
CommonStore.addEntry() called
    ↓
IntakeReminderManager.handleManualIntakeLogged()
    ↓
Cancels 8:00 AM reminder ✅
    ↓
Triggers background task
    ↓
Background task runs (within 15 mins - 24 hours)
    ↓
Reschedules next day's 8:00 AM reminder ✅
```

## Required Setup Steps

### Step 1: Update Info.plist

Add the background task identifier to your `Info.plist`:

**For Xcode GUI:**
1. Open your target settings
2. Go to "Info" tab
3. Add a new key: `BGTaskSchedulerPermittedIdentifiers`
4. Type: Array
5. Add item: `com.headydiscy.KeepTrack.refreshReminders` (String)

**For Info.plist XML:**
```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.headydiscy.KeepTrack.refreshReminders</string>
</array>
```

**Screenshot of what it should look like:**
```
▼ BGTaskSchedulerPermittedIdentifiers    Array    (1 item)
    ▸ Item 0                             String   com.headydiscy.KeepTrack.refreshReminders
```

### Step 2: Enable Background Modes

**For Xcode GUI:**
1. Select your target in Xcode
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "Background Modes"
5. Check "Background fetch"
6. Check "Background processing"

**For Info.plist XML (if editing directly):**
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

### Step 3: Import BackgroundTasks Framework

The new file `IntakeReminderBackgroundTask.swift` has already been created with the necessary imports.

### Step 4: Registration (Already Done ✅)

The background task is registered in `KeepTrackApp.swift`:
```swift
init() {
    // ... other setup ...
    
    // Register background task for reminder processing
    Task { @MainActor in
        IntakeReminderBackgroundTask.register()
    }
}
```

## Testing Background Tasks

### Simulator Testing (e-sim or physical device on iOS 15+)

Background tasks don't run automatically in the simulator/development. You need to manually trigger them:

**Using Xcode Console:**

1. Run your app from Xcode
2. Log an intake to trigger the background task scheduling
3. Pause the app in the debugger (or just background it)
4. In the Xcode debug console, run:

```lldb
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.headydiscy.KeepTrack.refreshReminders"]
```

5. Resume the app
6. Check the console for logs starting with "🔄 Background refresh started"

**Using Terminal (easier method):**

```bash
# While app is running on device/simulator, run:
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.headydiscy.KeepTrack"' --level debug

# In another terminal, trigger the background task:
xcrun simctl spawn booted e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.headydiscy.KeepTrack.refreshReminders"]
```

### Real-World Testing

On a physical device:
1. Build and install the app
2. Log an intake that has a scheduled reminder
3. Close the app completely
4. Wait (system decides when to run, usually within 15 min - 24 hours)
5. Check your notifications to see if reminders updated correctly

**To verify:**
- Create a goal for 2:00 PM daily
- Log intake at 1:00 PM
- Close app
- At 2:00 PM: No notification should fire ✅
- Next day at 2:00 PM: Notification should fire ✅

## Monitoring

The background task logs all activities to the system console. View logs using:

**Console.app (macOS):**
1. Open Console.app
2. Connect your device
3. Select your device
4. Filter by "KeepTrack"
5. Look for messages with 🔄, ✅, ❌ emojis

**Terminal:**
```bash
# On simulator
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.headydiscy.KeepTrack"'

# On physical device (connected via USB)
log stream --device --predicate 'subsystem == "com.headydiscy.KeepTrack"'
```

## Debugging Common Issues

### Background task not registered
**Symptoms:** No logs, background task never runs
**Fix:**
- Check Info.plist has correct identifier
- Check Background Modes capability is enabled
- Make sure `IntakeReminderBackgroundTask.register()` is called

### Background task runs but doesn't update reminders
**Symptoms:** Logs show "🔄 Background refresh started" but reminders still fire
**Fix:**
- Check `processAllReminders()` logs
- Verify goals are loaded correctly
- Check if `shouldSuppressReminder()` logic is working

### Background task scheduled but never runs
**Symptoms:** App schedules task, but system never executes it
**Explanation:** 
- iOS controls when background tasks run based on:
  - Device usage patterns
  - Battery level
  - Network conditions
  - App usage frequency
- System may delay or skip tasks entirely
**Fix:**
- Use manual simulation for testing
- On production, background tasks run more reliably for frequently-used apps

## Best Practices

1. **Don't rely solely on background tasks** - The foreground logic in `IntakeReminderManager+ManualEntry.swift` provides immediate cancellation
2. **Background tasks are a safety net** - They ensure reminders stay synced even if the app is force-quit
3. **Test thoroughly** - Use both simulation and real-world testing
4. **Monitor battery impact** - Background tasks use battery; keep processing efficient

## Architecture

**Files involved:**
- `IntakeReminderBackgroundTask.swift` - Background task implementation
- `IntakeReminderManager+ManualEntry.swift` - Triggers background processing
- `IntakeReminderManager.swift` - Core reminder logic
- `KeepTrackApp.swift` - Registers background task
- `CommonStore.swift` - Calls manual entry handler

**Flow:**
```
┌─────────────────────────────────────┐
│ User logs intake                    │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ CommonStore.addEntry()              │
│  └─ cancelPendingNotifications...() │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ IntakeReminderManager               │
│  .handleManualIntakeLogged()        │
│  └─ Cancels current reminder        │
│  └─ Triggers background task        │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ Background Task (later)             │
│  └─ Checks all goals                │
│  └─ Cancels logged reminders        │
│  └─ Reschedules next occurrences    │
└─────────────────────────────────────┘
```

## Manual Control

### Manually trigger background processing:
```swift
// Anywhere in your code
Task { @MainActor in
    IntakeReminderBackgroundTask.scheduleBackgroundRefresh()
}
```

### Process reminders immediately (foreground):
```swift
// Anywhere in your code
Task { @MainActor in
    await IntakeReminderBackgroundTask.processAllReminders()
}
```

### Check pending reminders:
```swift
let count = await IntakeReminderManager.getPendingReminderCount()
print("Pending reminders: \(count)")

let requests = await IntakeReminderManager.getPendingRequests()
for request in requests {
    print("ID: \(request.identifier)")
    if let trigger = request.trigger as? UNCalendarNotificationTrigger,
       let nextDate = trigger.nextTriggerDate() {
        print("Next fire: \(nextDate)")
    }
}
```

## Performance Considerations

- **Background tasks have ~30 seconds** to complete before the system terminates them
- The task processes goals sequentially - if you have many goals, consider batching
- Task schedules itself to run again after completion (perpetual maintenance)
- System may rate-limit if tasks run too frequently or take too long

## Privacy & Permissions

- Background tasks **do not require special user permissions**
- They run using the app's existing notification permissions
- User data stays on-device; no network requests needed
- Background tasks respect Low Power Mode (may be delayed or skipped)

## Next Steps

1. ✅ Add `BGTaskSchedulerPermittedIdentifiers` to Info.plist
2. ✅ Enable Background Modes capability
3. ✅ Test using console simulation
4. ✅ Verify in production with real usage
5. 📊 Monitor logs to ensure proper operation

## Troubleshooting Commands

```bash
# View background task schedule on simulator
xcrun simctl spawn booted log show --predicate 'subsystem == "com.apple.BackgroundTaskManagement"' --info --debug --last 1h

# Force background task execution
xcrun simctl spawn booted e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.headydiscy.KeepTrack.refreshReminders"]

# Check pending notifications
# (Run while debugging)
po await UNUserNotificationCenter.current().pendingNotificationRequests()
```

---

**Questions or issues?** Check the system console logs for detailed error messages and activity reports.
