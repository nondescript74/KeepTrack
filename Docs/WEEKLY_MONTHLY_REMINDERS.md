# Weekly and Monthly Reminder Support

## Overview
KeepTrack now fully supports reminders for goals with weekly, monthly, and daily frequencies. The reminder system intelligently handles different time intervals and properly suppresses notifications based on when intake was logged.

## Supported Frequencies

### Daily Frequencies
- **Daily** - Once per day
- **Twice a Day** - Two times per day (12 hours apart)
- **Three Times a Day** - Three times per day (6 hours apart)
- **Four Times a Day** - Four times per day (4 hours apart)
- **Six Times a Day** - Six times per day (2.5 hours apart)

### Weekly Frequencies
- **Weekly** - Once per week (same day/time)
- **Twice Weekly** - Two times per week (3 days apart)
- **Three Times Weekly** - Three times per week (Mon/Wed/Fri pattern)
- **Four Times Weekly** - Four times per week (every other day)

### Monthly Frequencies
- **Monthly** - Once per month (same day/time)
- **Twice Monthly** - Two times per month (15 days apart)
- **Three Times Monthly** - Three times per month (10 days apart)

## How It Works

### Date Array Generation (`matchingDateArray`)

When creating a goal, the system generates an array of dates based on the frequency:

**Daily Frequencies:**
```swift
// Example: Twice a Day starting at 8:00 AM
[
    8:00 AM (today),
    8:00 PM (today)  // +12 hours
]
```

**Weekly Frequencies:**
```swift
// Example: Three Times Weekly starting Monday 9:00 AM
[
    Monday 9:00 AM,
    Wednesday 9:00 AM,  // +2 days
    Friday 9:00 AM      // +4 days from start
]
```

**Monthly Frequencies:**
```swift
// Example: Twice Monthly starting on the 1st at 10:00 AM
[
    1st of month 10:00 AM,
    16th of month 10:00 AM  // +15 days
]
```

### Notification Scheduling

The `IntakeReminderManager.scheduleReminder()` function creates appropriate triggers based on frequency:

**Daily Reminders:**
```swift
var triggerDate = DateComponents()
triggerDate.hour = 8
triggerDate.minute = 0
// Repeats every day at 8:00 AM
```

**Weekly Reminders:**
```swift
var triggerDate = DateComponents()
triggerDate.weekday = 2  // Monday
triggerDate.hour = 9
triggerDate.minute = 0
// Repeats every Monday at 9:00 AM
```

**Monthly Reminders:**
```swift
var triggerDate = DateComponents()
triggerDate.day = 15  // 15th of month
triggerDate.hour = 10
triggerDate.minute = 0
// Repeats on the 15th of every month at 10:00 AM
```

### Notification Identifiers

Identifiers are formatted to distinguish between frequency types:

- **Daily:** `reminder-{goalID}-{hour}-{minute}`
- **Weekly:** `reminder-{goalID}-w{weekday}-{hour}-{minute}`
- **Monthly:** `reminder-{goalID}-d{day}-{hour}-{minute}`

Examples:
```
reminder-ABC123-8-0              // Daily at 8:00 AM
reminder-ABC123-w2-9-0           // Weekly on Monday at 9:00 AM
reminder-ABC123-d15-10-0         // Monthly on 15th at 10:00 AM
```

## Suppression Logic

### Daily Suppression
Checks if intake was logged **today** at or before the scheduled time:

```swift
// Reminder scheduled for 8:00 AM
// Entry logged at 7:45 AM → Suppress ✅
// Entry logged at 8:15 AM → Don't suppress ❌
```

### Weekly Suppression
Checks if intake was logged **this week on the same weekday** at or before the scheduled time:

```swift
// Reminder scheduled for Monday 9:00 AM
// Entry logged Monday 8:30 AM → Suppress ✅
// Entry logged Tuesday 9:00 AM → Don't suppress ❌ (different day)
// Entry logged last Monday 9:00 AM → Don't suppress ❌ (different week)
```

### Monthly Suppression
Checks if intake was logged **this month on the same day** at or before the scheduled time:

```swift
// Reminder scheduled for 15th at 10:00 AM
// Entry logged 15th at 9:00 AM → Suppress ✅
// Entry logged 14th at 10:00 AM → Don't suppress ❌ (different day)
// Entry logged last month 15th at 10:00 AM → Don't suppress ❌ (different month)
```

## User Experience Examples

### Example 1: Weekly Vitamin D
**Goal:** Take Vitamin D every Sunday at 9:00 AM

**Setup:**
1. Create intake type "Vitamin D"
2. Set frequency to "Weekly"
3. Choose Sunday 9:00 AM as start time
4. Enable reminders

**Behavior:**
- Notification fires every Sunday at 9:00 AM
- If user logs intake Sunday at 8:30 AM, reminder is suppressed
- If user misses Sunday, reminder won't fire again until next Sunday
- No "superseded reminder" logic needed (only one reminder per week)

### Example 2: Twice Weekly Physical Therapy
**Goal:** Do exercises Monday and Thursday at 6:00 PM

**Setup:**
1. Create intake type "PT Exercises"
2. Set frequency to "Twice Weekly"
3. Choose Monday 6:00 PM as start time (Thursday auto-scheduled)
4. Enable reminders

**Behavior:**
- Notifications fire Monday and Thursday at 6:00 PM
- Each day's reminder is independent
- If user logs Monday exercise, only Monday reminder suppressed
- Thursday reminder still fires normally

### Example 3: Monthly Medication
**Goal:** Take medication on the 1st and 15th at 8:00 AM

**Setup:**
1. Create intake type "Monthly Med"
2. Set frequency to "Twice Monthly"
3. Choose 1st at 8:00 AM as start time (15th auto-scheduled)
4. Enable reminders

**Behavior:**
- Notifications fire on 1st and 15th of each month at 8:00 AM
- If user takes med on 1st at 7:30 AM, that day's reminder suppressed
- 15th reminder unaffected
- Next month, cycle repeats

## Technical Implementation

### Key Files Modified

**1. Helper.swift - `matchingDateArray()`**
- Extended to handle weekly and monthly frequencies
- Calculates appropriate date offsets
- Returns array of dates spread across time period

**2. IntakeReminderManager.swift - `scheduleReminder()`**
- Detects frequency type from goal
- Creates appropriate `DateComponents` for trigger
- Uses weekday for weekly, day for monthly
- Generates descriptive identifiers

**3. IntakeReminderManager.swift - `shouldSuppressReminder()`**
- Implements frequency-specific suppression logic
- Uses `isDate(_:equalTo:toGranularity:)` for week/month checking
- Compares times within appropriate time periods

## Testing Weekly/Monthly Reminders

### Quick Test: Weekly
```swift
// Create a weekly goal with reminder 2 minutes from now
let testDate = Calendar.current.date(byAdding: .minute, value: 2, to: Date())!
// Set frequency to "Weekly"
// Notification fires in 2 minutes
// Will repeat next week same day/time
```

### Quick Test: Monthly
```swift
// Create a monthly goal with reminder 2 minutes from now
let testDate = Calendar.current.date(byAdding: .minute, value: 2, to: Date())!
// Set frequency to "Monthly"
// Notification fires in 2 minutes
// Will repeat next month same day/time
```

### Verifying Suppression

**Weekly:**
1. Create weekly goal for today at specific time
2. Log intake before reminder time
3. Verify reminder doesn't fire
4. Next week, reminder fires normally

**Monthly:**
1. Create monthly goal for today (current day of month)
2. Log intake before reminder time
3. Verify reminder doesn't fire
4. Next month same day, reminder fires normally

## Console Output

Look for these messages when testing:

**Scheduling:**
```
Scheduled weekly reminder: reminder-ABC123-w2-9-0
Scheduled monthly reminder: reminder-ABC123-d15-10-0
```

**Suppression:**
```
Should suppress: true (weekly reminder, intake logged this week)
Should suppress: true (monthly reminder, intake logged this month)
```

## Edge Cases Handled

### 1. Month with Fewer Days
**Scenario:** Monthly reminder set for 31st, but month only has 30 days

**Handling:** iOS automatically adjusts to last day of month (30th)

### 2. Daylight Saving Time
**Scenario:** Reminder scheduled during DST transition

**Handling:** iOS Calendar handles DST transitions automatically

### 3. Leap Year February 29th
**Scenario:** Monthly reminder on Feb 29th, non-leap year

**Handling:** iOS skips February in non-leap years, fires in March

### 4. Multiple Weekly Reminders Same Day
**Scenario:** Two different goals both weekly on Monday

**Handling:** Each goal has unique identifier, both fire independently

## Limitations & Considerations

### Current Limitations
1. **Fixed Day Patterns:** Weekly/monthly use fixed day patterns, not custom days
2. **Single Time Per Occurrence:** Each occurrence has one time, can't vary by week/month
3. **No Skip Logic:** Can't skip specific weeks/months (e.g., every other week)

### Future Enhancements
Possible improvements:
- Custom day selection for weekly (e.g., Mon/Wed/Fri specifically chosen)
- Variable times per occurrence
- Every-other-week / every-other-month options
- Skip specific dates (holidays, vacations)
- Seasonal schedules (summer vs winter dosages)

## Debugging

### Check Pending Weekly/Monthly Reminders
```swift
Task {
    let center = UNUserNotificationCenter.current()
    let requests = await center.pendingNotificationRequests()
    
    for request in requests {
        print("ID: \(request.identifier)")
        if let trigger = request.trigger as? UNCalendarNotificationTrigger {
            print("Date Components: \(trigger.dateComponents)")
            print("Next fire: \(trigger.nextTriggerDate() ?? Date())")
        }
    }
}
```

### Verify Frequency Detection
```swift
let goal = // your goal
let isDailyFrequency = goal.frequency.contains("Day") || goal.frequency == frequency.daily.rawValue
let isWeeklyFrequency = goal.frequency.contains("Weekly") || goal.frequency == frequency.weekly.rawValue
let isMonthlyFrequency = goal.frequency.contains("Monthly") || goal.frequency == frequency.monthly.rawValue

print("Daily: \(isDailyFrequency), Weekly: \(isWeeklyFrequency), Monthly: \(isMonthlyFrequency)")
```

## Summary

The reminder system now fully supports:
✅ Daily frequencies (multiple times per day)
✅ Weekly frequencies (specific weekdays)
✅ Monthly frequencies (specific days of month)
✅ Intelligent suppression for all frequency types
✅ Proper identifier formatting for debugging
✅ Automatic scheduling with iOS Calendar APIs
✅ All existing smart features (Confirm/Cancel, supersession for daily)

Users can now set reminders for any time interval and the system will handle notifications and suppression appropriately!
