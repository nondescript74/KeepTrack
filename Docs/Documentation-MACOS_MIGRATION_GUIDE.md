# macOS Migration Guide for KeepTrack

## Overview
This guide outlines the steps and considerations for adding macOS as a supported destination for the KeepTrack app.

## Files Already Updated
✅ **PlatformAdaptive.swift** - Created helper utilities for cross-platform support
✅ **SettingsView.swift** - Updated navigation and toolbar placements
✅ **BackupRestoreView.swift** - Updated navigation and toolbar placements

## Additional Files That Will Need Updates

### 1. Views with Navigation Bar Title Display Mode
Search for `.navigationBarTitleDisplayMode()` and replace with `.navigationBarTitleDisplayModeAdaptive()`

**Files likely affected:**
- Any view with `NavigationStack` or `NavigationView`
- Main content views
- Detail views
- Modal/sheet presentations

**Find and Replace:**
```
Find: .navigationBarTitleDisplayMode(
Replace: .navigationBarTitleDisplayModeAdaptive(
```

### 2. Views with Toolbar Items
Search for `.topBarTrailing`, `.topBarLeading`, `.bottomBar` and update to adaptive placements

**Common replacements:**
- `.topBarTrailing` → `.adaptiveTrailing` or `.adaptiveConfirmation`
- `.topBarLeading` → `.adaptiveCancellation`
- `.confirmationAction` → Already works on macOS (keep as is)
- `.cancellationAction` → Already works on macOS (keep as is)

### 3. List Styles
For settings-like views, consider using `.listStyleAdaptive()` which applies:
- `.insetGrouped` on iOS/iPadOS
- `.inset(alternatesRowBackgrounds: true)` on macOS

### 4. User Notifications (if applicable)
If you have notification-related code, you'll need platform-specific handling:

```swift
#if os(iOS)
import UserNotifications
#endif

// Request authorization
func requestNotificationPermission() async {
    #if os(iOS)
    let center = UNUserNotificationCenter.current()
    try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    #elseif os(macOS)
    // macOS uses NSUserNotificationCenter or UNUserNotificationCenter (10.14+)
    let center = UNUserNotificationCenter.current()
    try? await center.requestAuthorization(options: [.alert, .sound])
    #endif
}
```

### 5. Platform-Specific UI Considerations

#### SwiftData & CloudKit
✅ **Good news:** SwiftData and CloudKit work identically on macOS
- No changes needed for your data layer
- iCloud sync works cross-platform automatically

#### File Import/Export
✅ **Good news:** `.fileExporter()` and `.fileImporter()` work on macOS
- Already using these in BackupRestoreView
- No changes needed

#### Sheets and Modals
On macOS, sheets appear as separate windows. Consider:
- Setting minimum frame sizes for sheets: `.modalFrameAdaptive()`
- Some sheets may benefit from being presented differently on macOS

### 6. App Menu Bar (macOS Only)
Consider adding a Settings command to the app menu:

```swift
// In your App file
#if os(macOS)
import SwiftUI

@main
struct KeepTrackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    // Show settings
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}
#endif
```

### 7. Keyboard Shortcuts
macOS users expect keyboard shortcuts. Consider adding:
- ⌘N - New intake entry
- ⌘, - Settings
- ⌘W - Close window
- ⌘Q - Quit app

```swift
.keyboardShortcut("n", modifiers: .command)
```

## Testing Checklist

### Functional Testing
- [ ] SwiftData persistence works
- [ ] iCloud sync functions properly
- [ ] File export saves correctly
- [ ] File import reads correctly
- [ ] Backup creation successful
- [ ] Backup restoration successful
- [ ] All navigation flows work
- [ ] Settings persist correctly

### UI/UX Testing
- [ ] All views display correctly
- [ ] Navigation transitions are smooth
- [ ] Toolbars have appropriate buttons
- [ ] Lists display properly
- [ ] Sheets/modals sized appropriately
- [ ] Colors adapt to light/dark mode
- [ ] Text is readable and properly sized
- [ ] Icons display correctly

### macOS-Specific Testing
- [ ] Window resizing works properly
- [ ] Menu bar commands function
- [ ] Keyboard shortcuts work
- [ ] Trackpad gestures work
- [ ] Multiple windows (if supported)
- [ ] Full-screen mode
- [ ] Split view compatibility

## Common Build Errors and Solutions

### Error: "Use of unavailable API"
**Solution:** Wrap in platform check
```swift
#if os(iOS)
// iOS-only code
#elseif os(macOS)
// macOS-only code
#endif
```

### Error: "'navigationBarTitleDisplayMode' is unavailable in macOS"
**Solution:** Use `.navigationBarTitleDisplayModeAdaptive()` from PlatformAdaptive.swift

### Error: Toolbar placement warnings
**Solution:** Use adaptive placements like `.adaptiveConfirmation`, `.adaptiveCancellation`

### Error: Color initialization issues
**Solution:** Use platform-specific color initializers:
```swift
#if os(macOS)
Color(nsColor: .windowBackgroundColor)
#else
Color(uiColor: .systemBackground)
#endif
```

Or use `.adaptiveBackground` from PlatformAdaptive.swift

## Step-by-Step Migration Process

### Phase 1: Add macOS Destination
1. Open project settings in Xcode
2. Select your app target
3. Add macOS to Supported Destinations
4. Build and note all errors

### Phase 2: Fix Compilation Errors
1. Update all `.navigationBarTitleDisplayMode()` calls
2. Fix toolbar placements
3. Wrap iOS-only APIs in `#if os(iOS)` checks
4. Update color and UI component initializers

### Phase 3: UI Refinement
1. Test all views on macOS
2. Adjust frame sizes for sheets/modals
3. Update list styles where appropriate
4. Add keyboard shortcuts

### Phase 4: Feature Parity
1. Ensure all features work on macOS
2. Test iCloud sync between iOS and macOS
3. Test backup/restore across platforms
4. Verify notifications (if applicable)

### Phase 5: Polish
1. Add macOS-specific menu items
2. Optimize for macOS window management
3. Add appropriate keyboard shortcuts
4. Test with VoiceOver on macOS

## Platform Capabilities Matrix

| Feature | iOS/iPadOS | macOS | Notes |
|---------|-----------|-------|-------|
| SwiftData | ✅ | ✅ | Works identically |
| CloudKit Sync | ✅ | ✅ | Works identically |
| File Export | ✅ | ✅ | `.fileExporter()` works |
| File Import | ✅ | ✅ | `.fileImporter()` works |
| Notifications | ✅ | ✅ | Different authorization flow |
| App Intents | ✅ | ⚠️ | Limited on macOS |
| Widgets | ✅ | ✅ | Different placement |
| Live Activities | ✅ | ❌ | iOS/iPadOS only |

## Resources

### Apple Documentation
- [SwiftUI Platform Differences](https://developer.apple.com/documentation/swiftui)
- [Conditional Compilation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/#os)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)

### Key Platform Checks
```swift
#if os(iOS)
    // iOS and iPadOS
#elseif os(macOS)
    // macOS
#elseif os(watchOS)
    // watchOS
#elseif os(tvOS)
    // tvOS
#endif
```

### Device Idiom (Runtime Check)
```swift
#if os(iOS)
if UIDevice.current.userInterfaceIdiom == .pad {
    // iPad-specific code
} else {
    // iPhone-specific code
}
#endif
```

## Next Steps

1. **Add macOS destination in Xcode** and build to see all errors
2. **Work through compilation errors** systematically
3. **Update remaining views** with adaptive modifiers
4. **Test thoroughly** on both platforms
5. **Consider macOS-specific enhancements** like menu commands and keyboard shortcuts

## Questions to Consider

- Should the macOS app have a preferences window separate from the main window?
- Do you want to support multiple windows on macOS?
- Should there be macOS-specific features (menu bar app, dock badge, etc.)?
- How should notifications be handled differently on macOS?

---

**Note:** The PlatformAdaptive.swift file provides ready-to-use helpers for most common cross-platform scenarios. Import this in any view that needs platform-specific behavior.
