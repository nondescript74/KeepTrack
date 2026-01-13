# ⚡ Quick Setup: Info.plist Configuration

## You need to add this to your Info.plist file:

### Method 1: Using Xcode GUI (Recommended)

1. **Open Info.plist in Xcode**
   - Select your project in the navigator
   - Select your app target
   - Go to the "Info" tab

2. **Add Background Task Identifier**
   - Hover over any key and click the `+` button
   - Add new key: `BGTaskSchedulerPermittedIdentifiers`
   - Set type to: `Array`
   - Expand the array by clicking the triangle
   - Click the `+` to add an item
   - Item 0 type: `String`
   - Item 0 value: `com.headydiscy.KeepTrack.refreshReminders`

3. **Enable Background Modes**
   - Go to "Signing & Capabilities" tab
   - Click "+ Capability" button
   - Search for and add "Background Modes"
   - Check these boxes:
     - ✅ Background fetch
     - ✅ Background processing

### Method 2: Edit Info.plist XML Directly

Right-click Info.plist → Open As → Source Code

Add these lines inside `<dict>...</dict>`:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.headydiscy.KeepTrack.refreshReminders</string>
</array>

<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

## Visual Guide

Your Info.plist should look like this when done:

```
Information Property List                  Dictionary  (... items)
  ├─ BGTaskSchedulerPermittedIdentifiers   Array       (1 item)
  │  └─ Item 0                             String      com.headydiscy.KeepTrack.refreshReminders
  │
  ├─ UIBackgroundModes                     Array       (2 items)
  │  ├─ Item 0                             String      fetch
  │  └─ Item 1                             String      processing
  │
  └─ ... (other existing keys)
```

## Verify It Worked

**Build and run your app. Check the console for:**

```
✅ Background task registered: com.headydiscy.KeepTrack.refreshReminders
```

If you see this log, you're all set! ✅

If you see an error about "unknown task identifier", double-check:
- Spelling of the identifier (must match exactly)
- That you added it to the correct target's Info.plist
- That you cleaned and rebuilt the project (Product → Clean Build Folder)

## Test It

After setup, test the background task:

1. Run the app from Xcode
2. Log an intake item
3. Pause app in debugger (or background it)
4. In Xcode debug console, paste:

```lldb
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.headydiscy.KeepTrack.refreshReminders"]
```

5. Look for log: `🔄 Background refresh started`

---

**That's it!** Your app now supports background reminder processing. 🎉

See `BACKGROUND_TASK_SETUP.md` for detailed documentation.
