# macOS Migration Quick Reference

## Immediate Action Items

### 1️⃣ Add macOS as a Destination
- Open your Xcode project
- Select the KeepTrack target
- Go to "General" tab
- Under "Supported Destinations" click the + and add "Mac (Designed for iPad)"
  - This runs your iPad app on macOS with minimal changes
  - OR choose "Mac" for a native macOS app

### 2️⃣ Try Building
Press ⌘B to build and see what errors appear.

---

## Common Error Patterns & Quick Fixes

### ❌ Error: "navigationBarTitleDisplayMode is unavailable in macOS"
**Quick Fix:**
```swift
// BEFORE
.navigationBarTitleDisplayMode(.inline)

// AFTER
.navigationBarTitleDisplayModeAdaptive(.inline)
```

### ❌ Error: "topBarTrailing is unavailable in macOS"
**Quick Fix:**
```swift
// BEFORE
ToolbarItem(placement: .topBarTrailing) { ... }

// AFTER
ToolbarItem(placement: .adaptiveTrailing) { ... }

// OR for Done/Cancel buttons
ToolbarItem(placement: .adaptiveConfirmation) { ... }
```

### ❌ Error: "listStyle insetGrouped is unavailable in macOS"
**Quick Fix:**
```swift
// BEFORE
.listStyle(.insetGrouped)

// AFTER
.listStyleAdaptive()
```

### ❌ Error: Color/UIColor issues
**Quick Fix:**
```swift
// BEFORE
Color(uiColor: .systemBackground)

// AFTER
Color.adaptiveBackground

// OR manually
#if os(macOS)
Color(nsColor: .windowBackgroundColor)
#else
Color(uiColor: .systemBackground)
#endif
```

---

## Files Already Fixed ✅

1. **PlatformAdaptive.swift** - Helper utilities (NEW FILE)
2. **SettingsView.swift** - Navigation and toolbars
3. **BackupRestoreView.swift** - Navigation and toolbars

---

## Search & Replace Guide

Use Xcode's Find & Replace (⌘⇧F) to batch fix issues:

### Search Pattern 1: Navigation Bar Title Display Mode
```
Find:    .navigationBarTitleDisplayMode(
Replace: .navigationBarTitleDisplayModeAdaptive(
```

### Search Pattern 2: Top Bar Trailing Toolbar
```
Find:    .topBarTrailing
Replace: .adaptiveTrailing
```

### Search Pattern 3: Top Bar Leading Toolbar
```
Find:    .topBarLeading
Replace: .adaptiveCancellation
```

⚠️ **Note:** Review each replacement to ensure it makes sense in context!

---

## View-by-View Checklist

As you fix each view file, check off these items:

### For Each View:
- [ ] Import statement includes `import SwiftUI`
- [ ] No iOS-only imports (like `UIKit` unless wrapped in `#if os(iOS)`)
- [ ] Navigation modifiers use adaptive versions
- [ ] Toolbar placements use adaptive versions
- [ ] List styles use adaptive versions (if needed)
- [ ] Colors use adaptive versions (if needed)
- [ ] File builds without errors
- [ ] View displays correctly on macOS

---

## Platform Check Template

When you need to do something different on macOS vs iOS:

```swift
#if os(macOS)
// macOS-specific code
// Example: Different menu, different layout, etc.
#else
// iOS/iPadOS code
#endif
```

For runtime checks (less common, prefer compile-time):

```swift
if Platform.isMacOS {
    // macOS behavior
} else {
    // iOS behavior
}
```

---

## Testing Strategy

### 1. Build First
- Build for Mac (⌘B with Mac selected as destination)
- Fix all compilation errors

### 2. Run & Test Core Features
- [ ] App launches
- [ ] Main view displays
- [ ] Navigation works
- [ ] Can create/edit/delete entries
- [ ] Settings view opens and saves
- [ ] Backup export works
- [ ] Backup import works

### 3. Test Data Sync
- [ ] Create data on Mac
- [ ] Verify it syncs to iOS device (via iCloud)
- [ ] Create data on iOS
- [ ] Verify it syncs to Mac

### 4. UI Polish
- [ ] All sheets/modals are properly sized
- [ ] Colors look good in light mode
- [ ] Colors look good in dark mode
- [ ] Text is readable
- [ ] Icons display correctly
- [ ] Lists scroll smoothly

---

## Gotchas to Watch For

### 1. State Object Initialization
Works the same on macOS - no changes needed. ✅

### 2. SwiftData & ModelContext
Works the same on macOS - no changes needed. ✅

### 3. FileDocument & FileExporter
Works the same on macOS - no changes needed. ✅

### 4. @Query
Works the same on macOS - no changes needed. ✅

### 5. App Intents
⚠️ **May have limited functionality on macOS.** Test your AddSomethingIntent and AddMorningMedsIntent shortcuts.

### 6. User Notifications
⚠️ **Different on macOS.** If you have notification scheduling, you'll need to test and possibly adapt.

---

## When You Get Stuck

### Error: Can't figure out what's iOS-only
1. Option-click the API in Xcode
2. Look for "Availability" section
3. If it says "iOS 14.0+, iPadOS 14.0+" but NO macOS, it's iOS-only

### Error: View looks weird on macOS
- Try adding `.frame(minWidth: 600, minHeight: 400)` to sheets
- Consider different list styles
- Check if padding/spacing needs adjustment

### Error: "Mac (Designed for iPad)" vs "Mac"
- **Mac (Designed for iPad)**: Easiest path, runs iPad UI on Mac with minimal changes
- **Mac (Native)**: Full macOS native app, requires more adaptation but better UX

---

## Helpful Xcode Shortcuts

- **⌘B** - Build
- **⌘R** - Run
- **⌘⇧F** - Find in Project (for search & replace)
- **⌘⇧O** - Open Quickly (find files)
- **⌘⇧K** - Clean Build Folder (if things get weird)

---

## Priority Order

1. **Critical** - Fix all build errors (app won't run otherwise)
2. **High** - Fix navigation and toolbar issues (UX will be broken)
3. **Medium** - Fix list styles and colors (UX will be poor)
4. **Low** - Add keyboard shortcuts and Mac-specific features (nice to have)

---

## Expected Timeline

- **Quick Path (Mac Designed for iPad)**: 1-2 hours
- **Native Mac Path**: 4-8 hours depending on complexity

---

## Success Criteria

You'll know you're done when:
- ✅ Project builds without errors for Mac destination
- ✅ App launches and runs on macOS
- ✅ All core features work (create/edit/delete entries)
- ✅ Backup/restore works
- ✅ iCloud sync works between iOS and macOS
- ✅ No obvious UI glitches or layout issues

---

**Remember:** Start by just getting it to build and run. Polish comes later! 🚀
