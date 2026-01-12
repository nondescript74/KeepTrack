# System Permissions and iCloud Check Implementation

## Overview
This implementation adds comprehensive permission checking for iCloud Drive, CloudKit, and storage access to ensure the app can properly save backups and sync data. The system checks permissions on startup and displays warnings when issues are detected.

## Files Created

### 1. `ManagersSystemPermissionsChecker.swift`
A singleton manager that checks system permissions and capabilities:

**Features:**
- Checks iCloud availability (if user is signed in)
- Checks iCloud Drive accessibility 
- Verifies CloudKit account status
- Tests document directory read/write access
- Generates user-friendly warning messages
- Saves permission status to SwiftData

**Key Methods:**
- `checkAllPermissions()` - Performs all checks on app startup
- Private check methods for each permission type
- Warning generation based on missing permissions

**Permission Checks:**
1. **iCloud Available** - Checks if user is signed in to iCloud
2. **iCloud Drive Enabled** - Verifies iCloud Drive container access
3. **CloudKit Available** - Checks CloudKit account status (available, no account, restricted, etc.)
4. **Documents Accessible** - Creates test file to verify read/write permissions

### 2. `ViewsPermissionWarningBanner.swift`
SwiftUI views for displaying permission warnings:

**Components:**
- `PermissionWarningBanner` - Top banner for dashboard showing critical warnings
- `PermissionStatusCard` - Detailed card view with refresh button
- `PermissionStatusCardForSettings` - Standalone version for Settings screen

**Features:**
- Color-coded warnings (red for critical, orange for warnings, blue for info)
- Dismissible banner with X button
- "Open Settings" button to navigate to iOS Settings
- Relative timestamp showing when last checked
- Refresh button to re-run checks

### 3. `ViewsDashboardWithPermissionBanner.swift`
Wrapper view for adding permission banners to any content:

**Usage:**
```swift
DashboardWithPermissionBanner {
    // Your main content
}
.environmentObject(permissionsChecker)
```

## Files Modified

### 1. `ModelsSDAppSettings.swift`
Added permission tracking properties:
```swift
var iCloudAvailable: Bool = false
var cloudKitAvailable: Bool = false
var documentsAccessible: Bool = false
var lastPermissionCheck: Date?
```

### 2. `ManagersAutoBackupScheduler.swift`
Added permission check before performing backups:
- Checks `documentsAccessible` before attempting backup
- New error case: `BackupError_MABS.documentsNotAccessible`
- Prevents backup attempts when storage isn't accessible

### 3. `KeepTrackApp.swift`
Integrated permission checking on startup:
- Added `@StateObject` for `SystemPermissionsChecker.shared`
- Calls `checkAllPermissions()` in `.task` modifier
- Provides `permissionsChecker` as environment object

### 4. `SettingsView.swift`
Added "System Status" section:
- Displays current permission status
- Shows checkmarks/X for each permission
- "Refresh Status" button to re-run checks
- Helpful footer text explaining importance

## How It Works

### 1. App Startup Flow
```
App Launch
    ↓
LaunchScreen (0.7s)
    ↓
NewDashboard loads
    ↓
.task { } runs
    ↓
permissionsChecker.checkAllPermissions()
    ↓
Results displayed in banner (if issues found)
```

### 2. Permission Checking Process
```
checkAllPermissions()
    ↓
├─ checkiCloudStatus()
│  ├─ Check ubiquityIdentityToken (is user signed in?)
│  └─ Check ubiquity container URL (iCloud Drive enabled?)
│
├─ checkCloudKitStatus()
│  └─ Query CKContainer.accountStatus()
│     (available, noAccount, restricted, etc.)
│
├─ checkDocumentsAccess()
│  ├─ Create test directory
│  ├─ Write test file
│  ├─ Read test file
│  └─ Clean up test files
│
├─ updateWarnings()
│  └─ Generate user-friendly warning messages
│
└─ savePermissionStatus()
   └─ Save to SDAppSettings
```

### 3. Warning Severity Levels

**Critical (Red):**
- iCloud not available (not signed in)
- Cannot access documents directory

**Warning (Orange):**
- CloudKit unavailable (might still be signed in but issues with CloudKit)
- iCloud Drive disabled while iCloud is available

**Info (Blue):**
- Currently not used, available for informational messages

## User-Facing Messages

### iCloud Not Available
```
Title: "iCloud Not Available"
Message: "Please sign in to iCloud in Settings to enable data sync and backups."
Action: Open Settings button
```

### CloudKit Unavailable
```
Title: "CloudKit Unavailable"
Message: "Your data will not sync across devices. Check your iCloud settings."
Action: Open Settings button
```

### Storage Not Accessible
```
Title: "Cannot Access Storage"
Message: "The app cannot save backups. Please check storage permissions and available space."
Action: None (system-level issue)
```

### iCloud Drive Disabled
```
Title: "iCloud Drive Disabled"
Message: "Enable iCloud Drive in Settings to enable cloud backups."
Action: Open Settings button
```

## Settings Integration

The Settings screen now includes a "System Status" section that shows:

✅ **iCloud** - Required for sync and backups
✅ **CloudKit** - Syncs data across devices  
✅ **Storage Access** - Required for local backups

Each item shows:
- Green checkmark if available
- Red X if unavailable
- Description of what it's for

Plus:
- "Last checked: X ago" timestamp
- "Refresh Status" button to re-run checks

## Testing Checklist

### On Physical Device:

1. **Test iCloud Sign Out:**
   - Settings → [Your Name] → Sign Out
   - Launch app
   - Should see "iCloud Not Available" warning

2. **Test iCloud Drive Disabled:**
   - Sign in to iCloud
   - Settings → [Your Name] → iCloud → iCloud Drive → OFF
   - Launch app
   - Should see "iCloud Drive Disabled" warning

3. **Test Full Storage:**
   - Fill device storage to near capacity
   - App should detect and warn about storage issues

4. **Test Auto Backup:**
   - Enable auto backup in settings
   - Disable storage permissions (sign out of iCloud)
   - Wait for scheduled backup time
   - Check logs - should fail gracefully with proper error

5. **Test Settings Display:**
   - Go to Settings
   - Check "System Status" section
   - Tap "Refresh Status" button
   - Verify status updates

## Benefits

1. **Prevents Silent Failures** - User knows immediately if backups won't work
2. **Clear Guidance** - Tells user exactly what to do (sign in to iCloud, etc.)
3. **Graceful Degradation** - App continues to work locally even without iCloud
4. **Diagnostic Tool** - Settings screen helps troubleshoot sync issues
5. **Proactive Prevention** - Catches issues before data loss occurs

## Notes

- Permission checks run on every app launch
- Checks are lightweight and async
- User can dismiss warnings but they'll reappear on next launch until resolved
- All checks are @MainActor safe
- Uses OSLog for debugging in Console app
