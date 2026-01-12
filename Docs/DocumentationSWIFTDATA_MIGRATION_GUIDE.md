# SwiftData Schema Migration Guide

## Overview

This document explains how KeepTrack handles data migration from the old SwiftData schema (V1) to the new CloudKit-compatible schema (V2).

## Migration Scenarios

### Scenario 1: New Users
- **Status**: No migration needed
- **Action**: App creates V2 schema directly
- **Result**: Works perfectly with CloudKit from day one

### Scenario 2: Users Upgrading from JSON Storage
- **Status**: JSON → SwiftData V2
- **Migration**: Handled by `DataMigrationManager`
- **Result**: All JSON data migrated to V2 SwiftData
- **Tracked By**: `SwiftDataMigrationCompleted` UserDefaults key

### Scenario 3: Users with V1 SwiftData Schema
- **Status**: SwiftData V1 → SwiftData V2
- **Migration**: Automatic via `KeepTrackSchemaMigrationPlan`
- **Result**: Schema updated, all data preserved
- **Tracked By**: `CurrentSchemaVersion` UserDefaults key

## What Changed Between V1 and V2?

### V1 Schema (Old - Not CloudKit Compatible)
```swift
@Model
final class SDEntry {
    @Attribute(.unique) var id: UUID  // ❌ CloudKit doesn't support unique constraints
    var date: Date                     // ❌ No default value
    var units: String                  // ❌ No default value
    // ... other non-optional properties without defaults
}
```

### V2 Schema (Current - CloudKit Compatible)
```swift
@Model
final class SDEntry {
    var id: UUID = UUID()              // ✅ Default value, no unique constraint
    var date: Date = Date()            // ✅ Default value
    var units: String = ""             // ✅ Default value
    // ... all properties have defaults
}
```

## How Migration Works

### Automatic Schema Migration

SwiftData automatically migrates from V1 to V2 when:

1. **App launches** with V2 code but V1 database
2. **Migration Plan** detects version mismatch
3. **Core Data** performs lightweight migration:
   - Removes unique constraints
   - Adds default values to property definitions
   - **Data is preserved** - no data loss!

### Migration Flow

```
App Launch
    ↓
Check Schema Version
    ↓
    ├─→ V1 Detected → Automatic Migration to V2 → Record V2
    ├─→ V2 Detected → Continue normally
    └─→ No Schema → Check for JSON → Migrate JSON to V2
```

## Files Involved

### Core Migration Files

1. **`ManagersSwiftDataSchemaMigration.swift`**
   - Defines `KeepTrackSchemaV1` and `KeepTrackSchemaV2`
   - Contains migration plan
   - Logs migration progress

2. **`ManagersSchemaVersionChecker.swift`**
   - Tracks current schema version
   - Validates migration success
   - Creates pre-migration backups

3. **`ManagersSwiftDataManager.swift`**
   - Initializes ModelContainer with migration plan
   - Handles CloudKit configuration

4. **`ManagersDataMigrationManager.swift`**
   - Handles JSON → SwiftData migration
   - Export/import backup functionality

## Testing Migration

### Using the Debug View

Access the Migration Debug View to:
- Check current schema version
- Validate data integrity
- Create backups
- Force re-migration (for testing)

### Manual Testing Steps

1. **Test V1 → V2 Migration**:
   ```swift
   // Install old version with V1 schema
   // Add test data
   // Update to new version with V2 schema
   // Launch app - migration should happen automatically
   ```

2. **Verify Data Integrity**:
   ```swift
   let checker = SchemaVersionChecker.shared
   let report = try checker.validateMigration(context: modelContext)
   print(report)
   ```

3. **Check Console Logs**:
   ```
   🔄 Starting migration from V1 to V2 (removing unique constraints)
   ✅ Migration from V1 to V2 completed successfully
   📊 Migration results:
      - Entries: 150
      - Intake Types: 20
      - Goals: 5
      - Settings: 1
   ```

## Safety Features

### 1. Automatic Backup
The schema migration is **lightweight** and safe, but you can create manual backups:

```swift
let checker = SchemaVersionChecker.shared
let backupURL = try checker.createPreMigrationBackup()
```

### 2. Validation
After migration, validate data:

```swift
let report = try checker.validateMigration(context: modelContext)
if !report.isValid {
    print("⚠️ Migration issues detected: \(report)")
}
```

### 3. Rollback (Emergency)
If migration fails catastrophically:
1. User can reinstall old version
2. Restore from CloudKit (if signed in)
3. Restore from manual backup
4. Contact support with logs

## CloudKit Considerations

### First Sync After Migration
- V2 schema is CloudKit-compatible
- First sync may take longer (full upload)
- Ensure user is signed into iCloud
- Monitor for sync errors

### Sync Status
```swift
// Check CloudKit sync status
// Look for: "Unable to initialize without an iCloud account"
// This is normal if not signed into iCloud
```

## Troubleshooting

### Migration Doesn't Start
- Check UserDefaults: `CurrentSchemaVersion`
- Check console for migration logs
- Use Migration Debug View to force migration

### Data Missing After Migration
- Check validation report
- Look for console errors during migration
- Verify backup exists
- Check CloudKit sync status

### Migration Fails
- Check console logs for specific error
- Common issues:
  - Insufficient storage
  - Corrupted database
  - App Group configuration mismatch
- Solution: Use backup/restore

## Best Practices

### For Developers

1. **Always test migration with production-like data**
2. **Monitor console logs during first release**
3. **Provide clear communication to users**
4. **Keep backup functionality available**

### For Users

1. **Update when connected to WiFi**
2. **Ensure iCloud is signed in (optional but recommended)**
3. **Don't force quit during first launch after update**
4. **Check Settings → Storage for sufficient space**

## Future Schema Changes

To add future schema versions:

1. Create `KeepTrackSchemaV3` enum
2. Add to `schemas` array in migration plan
3. Add migration stage: `migrateV2toV3`
4. Update version checker logic
5. Test thoroughly!

## Support

If users experience migration issues:
1. Check console logs
2. Use Migration Debug View
3. Create backup
4. Reset migration flag if needed
5. Contact developer support

---

**Last Updated**: January 12, 2026
**Schema Version**: 2.0.0
**CloudKit**: ✅ Enabled
