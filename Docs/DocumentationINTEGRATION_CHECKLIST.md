# Backup & Restore Integration Checklist

## Pre-Integration Setup

### 1. Xcode Project Configuration

#### iCloud Capability
- [ ] Open project in Xcode
- [ ] Select your target → Signing & Capabilities
- [ ] Click "+ Capability" → Add "iCloud"
- [ ] Check "CloudKit"
- [ ] Verify container shows: `iCloud.com.headydiscy.KeepTrack`
  - If not, click "+" and add it
- [ ] Note: You may need to be signed in to your Apple Developer account

#### App Groups Capability
- [ ] Click "+ Capability" → Add "App Groups"
- [ ] Check the box for `group.com.headydiscy.KeepTrack`
  - If doesn't exist, click "+" and create it
- [ ] Verify it shows as enabled

#### Background Modes Capability
- [ ] Click "+ Capability" → Add "Background Modes"
- [ ] Check "Background fetch"
- [ ] Check "Remote notifications"

### 2. Entitlements File

- [ ] Verify `KeepTrack.entitlements` exists in project
- [ ] Open it and verify contains:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.headydiscy.KeepTrack</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.headydiscy.KeepTrack</string>
    </array>
</dict>
</plist>
```

### 3. Info.plist Updates

- [ ] Open `Info.plist`
- [ ] Add background task identifier:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.headydiscy.KeepTrack.autobackup</string>
</array>
```

## File Integration

### Models Folder

- [ ] Create `Models/` folder if doesn't exist
- [ ] Add `SDEntry.swift`
- [ ] Add `SDIntakeType.swift`
- [ ] Add `SDGoal.swift`
- [ ] Add `SDAppSettings.swift`
- [ ] Verify all files are added to target

### Managers Folder

- [ ] Create `Managers/` folder if doesn't exist
- [ ] Add `SwiftDataManager.swift`
- [ ] Add `DataMigrationManager.swift`
- [ ] Add `AutoBackupScheduler.swift`
- [ ] Verify all files are added to target

### Stores Folder

- [ ] Create `Stores/` folder if doesn't exist
- [ ] Add `SwiftDataStore.swift`
- [ ] Verify file is added to target

### Views Folder

- [ ] Locate existing `Views/` folder
- [ ] Add `BackupRestoreView.swift`
- [ ] Add `BackupStatusCard.swift`
- [ ] Add `BackupQuickActionsView.swift`
- [ ] Add `BackupManagementView.swift`
- [ ] Add `BackupHistoryView.swift`
- [ ] Add `SyncStatisticsView.swift`
- [ ] Add `MigrationDebugView.swift`
- [ ] Verify all files are added to target

### Update Existing Files

- [ ] Update `KeepTrackApp.swift` with migration code
- [ ] Update `SettingsView.swift` with backup integration
- [ ] Verify both files compile without errors

### Documentation Folder

- [ ] Create `Documentation/` folder if doesn't exist
- [ ] Add `BACKUP_RESTORE_README.md`
- [ ] Add `BACKUP_IMPLEMENTATION_SUMMARY.md`
- [ ] Add `BACKUP_ARCHITECTURE.md`
- [ ] Add `BackupSystemQuickStart.swift`

## Code Verification

### Imports Check

Verify these imports in key files:

```swift
// Models
import Foundation
import SwiftData

// Managers
import Foundation
import SwiftData
import OSLog
import BackgroundTasks  // AutoBackupScheduler only

// Views
import SwiftUI
import SwiftData
import UniformTypeIdentifiers  // For file export/import

// App
import SwiftUI
import SwiftData
import UserNotifications
```

- [ ] All imports present and correct

### Compilation Check

- [ ] Build project (⌘B)
- [ ] Fix any compilation errors
- [ ] No warnings related to backup system

## Testing on Simulator

### Initial Testing

- [ ] Run app in simulator
- [ ] Check Console for migration messages
- [ ] Should see: "✅ Initial data migration completed" or "Migration already completed"
- [ ] Navigate to Settings
- [ ] Verify BackupStatusCard appears
- [ ] Verify Quick Actions buttons appear

### Settings Navigation

- [ ] Tap "Backup & Restore"
- [ ] Verify view loads correctly
- [ ] Check all sections appear:
  - [ ] iCloud Sync status
  - [ ] Your Data statistics
  - [ ] Manual Backup buttons
  - [ ] Advanced section

- [ ] Tap "Sync Statistics"
- [ ] Verify statistics display correctly
- [ ] Check all data counts match expectations

### Export Test

- [ ] In Backup & Restore, tap "Export Backup"
- [ ] File picker should appear
- [ ] Save to Files app or simulator documents
- [ ] Verify success message appears
- [ ] Check "Last Backup" updates in settings

### Import Test

- [ ] Tap "Import Backup"
- [ ] Select previously exported file
- [ ] Choose "Merge with Existing"
- [ ] Verify success message

### Migration Tools

- [ ] Go to Backup & Restore → Advanced → Migration Tools
- [ ] Check migration status shows "Completed"
- [ ] (Optional) Test "Reset Migration Flag"

## Testing on Physical Device

### Required Setup

- [ ] iPhone/iPad with iOS 17.0+
- [ ] Signed into iCloud account
- [ ] iCloud Drive enabled
- [ ] Developer mode enabled (for testing)

### CloudKit Testing

- [ ] Install app on Device 1
- [ ] Add some test entries
- [ ] Go to Settings
- [ ] Verify iCloud Sync shows "Synced" (may take a moment)

- [ ] Install app on Device 2 (same iCloud account)
- [ ] Launch app
- [ ] Wait for sync (check Settings → Backup Status)
- [ ] Verify data appears from Device 1

- [ ] Add entry on Device 2
- [ ] Check Device 1 for sync

### Auto Backup Testing

⚠️ **Note**: Background tasks don't run reliably in simulator or when debugging

- [ ] On physical device, enable Settings → Auto Backup
- [ ] Verify shows "Next backup: in about 24 hours"
- [ ] (Optional) Use `e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.headydiscy.KeepTrack.autobackup"]` in Xcode console to trigger immediately
- [ ] Check Documents/Backups/ folder for backup file
- [ ] Verify Settings shows updated last backup time

### Backup History

- [ ] After auto backup runs, go to Backup History
- [ ] Verify backup appears in list
- [ ] Try long-press → Share
- [ ] Try swipe left → Delete

## CloudKit Dashboard Verification

- [ ] Go to https://icloud.developer.apple.com/
- [ ] Sign in with Apple Developer account
- [ ] Select CloudKit Dashboard
- [ ] Select your app: `iCloud.com.headydiscy.KeepTrack`
- [ ] Choose "Development" environment
- [ ] Click "Data" tab
- [ ] Verify record types exist:
  - [ ] SDEntry
  - [ ] SDIntakeType
  - [ ] SDGoal
  - [ ] SDAppSettings
- [ ] Click on SDEntry
- [ ] Verify your test records appear

## Common Issues & Solutions

### Issue: "No CloudKit Container"

**Solution:**
- Verify container ID matches in code and Xcode capabilities
- Check you're signed in to Apple Developer account
- Try cleaning build folder (⇧⌘K) and rebuilding

### Issue: "Migration not running"

**Solution:**
- Check Console for error messages
- Verify `SwiftDataMigrationCompleted` key in UserDefaults
- Use Migration Tools to reset and retry

### Issue: "Sync not working"

**Solution:**
- Verify iCloud is signed in on device
- Check internet connection
- Toggle iCloud Sync off/on in Settings
- Check CloudKit Dashboard for errors
- Try on different network (avoid corporate/school networks with restrictions)

### Issue: "Auto backup not running"

**Solution:**
- Test on physical device (doesn't work in simulator)
- Verify background task identifier in Info.plist
- Check Auto Backup is enabled in Settings
- Use Xcode console command to trigger manually for testing

### Issue: "Compilation errors"

**Solution:**
- Verify all imports are correct
- Check SwiftData is available (iOS 17.0+)
- Verify all files are added to target
- Clean build folder and rebuild

### Issue: "Data not migrating from JSON"

**Solution:**
- Check existing JSON files exist in App Group container
- Verify `CommonStore` and `CurrentIntakeTypes` still work
- Check Console for migration error messages
- Manually trigger migration from Migration Tools

## Performance Validation

### Expected Performance

- [ ] App launch: < 2 seconds
- [ ] Migration (first launch): < 10 seconds
- [ ] Add entry: < 100ms
- [ ] Export backup: < 2 seconds (for 1000 entries)
- [ ] Import backup: < 3 seconds
- [ ] Settings view load: < 500ms

### Memory Usage

- [ ] Check memory usage in Xcode (should be < 100MB typically)
- [ ] No memory leaks in Instruments
- [ ] No retain cycles in view models

## Production Readiness

### Final Checks

- [ ] All tests passing
- [ ] No compiler warnings
- [ ] No runtime errors in Console
- [ ] UI responsive on all screen sizes
- [ ] Dark mode tested
- [ ] Accessibility labels added (VoiceOver)
- [ ] Error messages are user-friendly
- [ ] Success feedback is clear

### Documentation

- [ ] README updated with backup features
- [ ] Release notes mention backup capability
- [ ] User guide includes backup instructions
- [ ] Support documentation updated

### App Store Preparation

- [ ] Privacy manifest updated (if required)
- [ ] App description mentions iCloud sync
- [ ] Screenshots show backup feature
- [ ] TestFlight beta tested with real users
- [ ] CloudKit set to Production environment

## Post-Launch Monitoring

### Week 1

- [ ] Monitor CloudKit usage in dashboard
- [ ] Check crash reports for backup-related issues
- [ ] Review user feedback about sync
- [ ] Verify auto backups running as expected

### Ongoing

- [ ] Monitor iCloud storage usage
- [ ] Check for sync conflicts
- [ ] Review backup file sizes
- [ ] Plan improvements based on usage data

## Rollback Plan

If issues arise:

1. [ ] Disable auto backup in app update
2. [ ] Keep manual export/import working
3. [ ] Preserve JSON storage as fallback
4. [ ] Provide migration reset tool
5. [ ] Update app with fix
6. [ ] Test thoroughly before re-enabling

---

## Sign-Off

- [ ] Development complete
- [ ] Testing complete
- [ ] Documentation complete
- [ ] Code reviewed
- [ ] Ready for deployment

**Completed by**: _________________
**Date**: _________________
**Version**: 1.0

---

**Notes**:
- Keep this checklist with your project documentation
- Check off items as you complete them
- Add notes about any issues encountered
- Update checklist for your specific needs
