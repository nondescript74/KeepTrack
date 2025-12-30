# Settings View Implementation Summary

## Overview
A comprehensive Settings view has been added to KeepTrack with license viewing, diagnostics, and data management capabilities.

## Files Created

### 1. SettingsView.swift
A complete Settings interface with the following sections:

#### App Information
- App version display
- Build number display

#### Legal
- View License Agreement (updated to support viewing mode)

#### Diagnostics
- **View Logs**: Browse, filter, and export OSLog entries
- **Export Diagnostics**: Share device and app information

#### Data Management
- Storage size calculation
- Data reset functionality (with confirmation)

#### About
- App name
- Bundle identifier

## Files Modified

### 1. LicenseView.swift
**Enhanced with dual-mode support:**

#### New ViewMode Enum
```swift
enum ViewMode {
    case acceptance  // Must accept to continue (initial launch)
    case viewing     // Just viewing from Settings (already accepted)
}
```

#### Changes Made:
- Added two initializers:
  - `init(licenseManager:onAccept:)` - For acceptance flow
  - `init(licenseManager:viewMode:)` - For viewing from Settings
- Accept button only shows in `.acceptance` mode
- Done button only shows in `.viewing` mode
- Shows acceptance date/version when viewing from Settings
- Dismissal protection only applies in `.acceptance` mode

### 2. License.md
**Updated with comprehensive legal terms:**

#### Key Additions:
- Updated date: December 27, 2025
- Enhanced **Health Disclaimer** with stronger warnings
- Added **User Responsibilities** section
- More detailed **Data and Privacy** section
- Added **Severability** and **No Waiver** clauses
- Clearer formatting and structure
- Mentions iCloud data storage option
- Emphasizes medication tracking safety

#### New Sections:
- Section 7: User Responsibilities
- Section 13: Severability
- Section 15: No Waiver
- Section 16: Contact

## Key Features

### Log Viewer
- Fetches OSLog entries from the last hour
- Filter by log level (Debug, Info, Notice, Error, Fault)
- Search functionality
- Color-coded display with icons
- Export logs as text file
- Uses `OSLogStore` API

### Data Management
- Calculates App Group container size
- Reset all data with confirmation
- Clear danger zone warnings

### Diagnostics Export
- App version and build info
- Device model and OS version
- Bundle identifier
- Timestamp
- Exportable as text file

## Integration

### How to Add Settings to Your App

Add a settings button to your main view:

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button {
            showingSettings = true
        } label: {
            Image(systemName: "gear")
        }
    }
}
.sheet(isPresented: $showingSettings) {
    SettingsView()
}
```

Or add it as a tab in a TabView:

```swift
TabView {
    // Your main views...
    
    SettingsView()
        .tabItem {
            Label("Settings", systemImage: "gear")
        }
}
```

## Usage Examples

### Viewing License from Settings
```swift
// This is already implemented in SettingsView
LicenseView(licenseManager: LicenseManager(), viewMode: .viewing)
```

### First-time License Acceptance
```swift
// Your existing flow
LicenseView(licenseManager: LicenseManager()) {
    // Handle acceptance
    licenseManager.acceptLicense()
}
```

## Dependencies

The SettingsView requires:
- `LicenseView.swift` and `LicenseManager.swift`
- `License.md` file in the bundle
- OSLog framework (already in use)
- UIKit for share sheet presentation

## Technical Notes

### OSLog Access
The log viewer uses `OSLogStore` which requires:
- iOS 15.0+
- Access to current process logs only
- Fetches last hour by default (configurable)

### App Group Container
Data management features use the App Group:
```swift
"group.com.headydiscy.KeepTrack"
```

Make sure this App Group is properly configured in your Xcode project.

### Share Sheet Presentation
Uses UIKit's `UIActivityViewController` to present share sheets for:
- Diagnostic information export
- Log file export

## Privacy Considerations

The Settings view:
- Shows only device model, OS version (no personal identifiers)
- Logs are from current process only
- All exports are user-initiated
- No automatic data transmission

## Future Enhancements

Potential additions:
- [ ] Appearance settings (light/dark mode override)
- [ ] Notification preferences
- [ ] Backup/restore functionality
- [ ] Extended log time range selector
- [ ] Log filtering by category
- [ ] Support email link
- [ ] What's New view for version updates

## Testing

Preview providers are included for:
- `SettingsView`
- `LogViewerView`
- `DataManagementView`

Test in Xcode Previews or on device for full functionality.

## License Updates

When updating the license:
1. Edit `License.md` with new content
2. Update the "Last Updated" date
3. Update fallback text in `LicenseView.swift` (if needed)
4. Consider whether version bump requires re-acceptance

The `LicenseManager` tracks which version was accepted, enabling forced re-acceptance on major updates if needed.
