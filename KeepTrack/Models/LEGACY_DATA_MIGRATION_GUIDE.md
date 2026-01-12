# Legacy Data Migration Guide

## Overview

Your KeepTrack app is transitioning from **JSON-based storage** to **SwiftData with CloudKit sync**. This migration preserves all your existing data while enabling modern features like iCloud sync and improved performance.

## Data Storage Evolution

### Old System (JSON-based)
Your app previously stored data in these locations:

1. **Entries** (`CommonEntry`)
   - Location: App Group container via `AppGroupStorage`
   - Format: JSON files
   - Managed by: `CommonStore`

2. **Intake Types** (`IntakeType`)
   - Location: `intakeTypes.json` in App Group
   - Format: JSON file
   - Managed by: `CurrentIntakeTypes`

3. **Goals** (`CommonGoal`)
   - Location: `goalsstore.json` in Documents directory
   - Format: JSON file
   - Managed by: `CommonGoals`

4. **Settings**
   - Location: `UserDefaults`
   - Format: Key-value pairs

### New System (SwiftData + CloudKit)
Now your app uses:

1. **Entries** (`SDEntry`)
   - Storage: SwiftData with CloudKit sync
   - Location: App Group SQLite database
   - Features: Automatic sync, relationships, efficient querying

2. **Intake Types** (`SDIntakeType`)
   - Storage: SwiftData with CloudKit sync
   - Features: Linked to entries via relationships

3. **Goals** (`SDGoal`)
   - Storage: SwiftData with CloudKit sync
   - Features: Tracked across devices

4. **Settings** (`SDAppSettings`)
   - Storage: SwiftData with CloudKit sync
   - Features: Permission tracking, sync across devices

## Migration Process

### Automatic Migration Path: V0 → V1 → V2

#### Stage 1: V0 → V1 (JSON Import + Add Unique Constraints)

**What happens:**
1. SwiftData detects the database version
2. If SwiftData is **empty**, it imports your legacy JSON data:
   ```
   📦 Importing legacy JSON data into SwiftData...
   Found X entries in CommonStore JSON
   ✅ Imported X entries
   Found Y intake types in JSON
   ✅ Imported Y intake types
   Found Z goals in JSON
   ✅ Imported Z goals
   ✅ Created default settings
   🎉 Legacy JSON data import completed successfully!
   ```
3. If SwiftData already has data, it skips the JSON import
4. Adds `@Attribute(.unique)` constraints to ID fields

**Your data is safe:**
- ✅ Original JSON files remain untouched
- ✅ All entries, goals, and intake types are imported
- ✅ UUIDs and relationships are preserved
- ✅ No data loss

#### Stage 2: V1 → V2 (CloudKit Compatible)

**What happens:**
1. Removes `@Attribute(.unique)` constraints (CloudKit doesn't support them)
2. Adds new permission tracking fields to `SDAppSettings`:
   - `iCloudAvailable`
   - `cloudKitAvailable`
   - `documentsAccessible`
   - `lastPermissionCheck`
3. Updates timestamps
4. Validates data integrity

## What You'll See in Console

When you run your app after this update, watch for these logs:

```
🔄 Attempting to initialize with CloudKit sync and migration...
🔄 Starting migration from V0 to V1
   - Adding unique constraints
   - Checking for legacy JSON data to import
✅ Migration from V0 to V1 completed
📦 Importing legacy JSON data into SwiftData...
Found 247 entries in CommonStore JSON
✅ Imported 247 entries
Found 12 intake types in JSON
✅ Imported 12 intake types
Found 5 goals in JSON
✅ Imported 5 goals
✅ Created default settings
🎉 Legacy JSON data import completed successfully!
🔄 Starting migration from V1 to V2
   - Removing unique constraints (CloudKit compatible)
   - Adding new permission tracking fields to SDAppSettings
✅ Migration from V1 to V2 completed successfully
📊 Migration results:
   - Entries: 247
   - Intake Types: 12
   - Goals: 5
   - Settings: 1
✅ SwiftData container initialized with CloudKit sync
```

## Verification Steps

After migration, verify your data:

### 1. Check Entry Count
```swift
// In your app, entries should match your old CommonStore count
let entries = try modelContext.fetch(FetchDescriptor<SDEntry>())
print("Total entries: \(entries.count)")
```

### 2. Use Migration Status View
Add the `MigrationStatusView` to your settings:
```swift
NavigationLink("Migration Status") {
    MigrationStatusView()
}
```

This will show:
- Current schema version (V2)
- CloudKit sync status
- Data counts for all models
- Settings details

### 3. Check Your Data
- Open the app and navigate to your history
- Verify that all your previous entries are there
- Check intake types in your entry forms
- Verify goals are intact

## Legacy Data Preservation

**Important:** The migration does **NOT** delete your old JSON files. They remain as backups:

- `CommonStore` JSON files in App Group ✅ Preserved
- `intakeTypes.json` in App Group ✅ Preserved
- `goalsstore.json` in Documents ✅ Preserved

If you need to revert or troubleshoot, your original data is still there.

## Troubleshooting

### Problem: Migration doesn't import my data

**Solution:**
1. Check console logs for error messages
2. Verify JSON files exist:
   ```swift
   // Check App Group
   let appGroupID = "group.com.headydiscy.KeepTrack"
   if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
       let intakeTypesURL = containerURL.appendingPathComponent("intakeTypes.json")
       print("intakeTypes.json exists: \(FileManager.default.fileExists(atPath: intakeTypesURL.path))")
   }
   ```

### Problem: "Cannot use staged migration with an unknown model version"

**Solution:**
This error should now be fixed. The V0 schema represents your current unversioned database. If you still see this:
1. Check that `ManagersSwiftDataSchemaMigration.swift` includes V0
2. Verify `SwiftDataManager` is using the migration plan
3. Check console logs for specific error details

### Problem: Data appears duplicated

**Cause:** Migration ran multiple times

**Solution:**
The migration checks if data exists before importing:
```swift
let entryCount = try context.fetchCount(FetchDescriptor<SDEntryV1>())
if entryCount > 0 {
    logger.info("SwiftData already contains entries, skipping JSON import")
    return
}
```

If you see duplicates, it means the data was imported from multiple sources. You can use the `MigrationStatusView` to verify counts.

### Problem: CloudKit sync not working

**Possible causes:**
1. **Not signed into iCloud**: Check Settings app
2. **Missing entitlements**: Verify in Xcode:
   - Signing & Capabilities → iCloud → CloudKit
   - App Groups enabled with correct identifier
3. **Network issues**: Check internet connection

**Check status:**
```swift
let manager = SwiftDataManager.shared
print("CloudKit enabled: \(manager.isCloudKitEnabled)")
```

## Migration Complete Checklist

- [ ] App launches without crashes
- [ ] Console shows successful V0→V1→V2 migration
- [ ] Entry count matches your old data
- [ ] Intake types are available
- [ ] Goals are present
- [ ] CloudKit sync is enabled (if properly configured)
- [ ] No duplicate data
- [ ] Settings are preserved

## Future-Proofing

This migration system is designed for the future. When you need to add V3:

1. Create `KeepTrackSchemaV3` in the migration file
2. Add it to the `schemas` array
3. Create a new migration stage `migrateV2toV3`
4. Add the stage to `stages` array
5. Update `SwiftDataManager` to use V3

Your existing V0→V1→V2 migration path will continue working for users upgrading from older versions.

## Technical Details

### Migration Classes Used

1. **KeepTrackSchemaMigrationPlan**
   - Defines all schema versions (V0, V1, V2)
   - Defines migration stages
   - Handles JSON import logic

2. **SwiftDataManager**
   - Initializes ModelContainer with migration plan
   - Falls back to local storage if CloudKit fails
   - Provides main context for UI operations

3. **DataMigrationManager** (Optional)
   - Can be used for manual backup/restore
   - Exports SwiftData to JSON backup
   - Imports from JSON backup

### Schema Versions

```
V0 (Unversioned)
├── SDEntryV0
├── SDIntakeTypeV0
├── SDGoalV0
└── SDAppSettingsV0 (basic)

V1 (With Unique Constraints)
├── SDEntryV1 (@Attribute(.unique) on id)
├── SDIntakeTypeV1 (@Attribute(.unique) on id)
├── SDGoalV1 (@Attribute(.unique) on id)
└── SDAppSettingsV1 (@Attribute(.unique) on id)

V2 (CloudKit Compatible - Current)
├── SDEntry (no unique constraints)
├── SDIntakeType (no unique constraints)
├── SDGoal (no unique constraints)
└── SDAppSettings (+ permission tracking fields)
```

## Support

If you encounter issues:

1. Check the console logs first
2. Use `MigrationStatusView` to see current state
3. Verify your JSON files are accessible
4. Ensure App Group configuration is correct
5. Check CloudKit dashboard for sync status

---

**Migration Date**: January 12, 2026  
**Migration Path**: V0 (JSON + Unversioned SwiftData) → V1 (Unique Constraints) → V2 (CloudKit Compatible)  
**Status**: ✅ Ready for production
