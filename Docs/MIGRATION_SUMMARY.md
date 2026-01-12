# SwiftData Migration Summary

## What We Fixed

Your app was crashing with the error:
```
Cannot use staged migration with an unknown model version.
```

This happened because:
1. Your device had an existing SwiftData database from before migrations were implemented
2. The migration plan only defined V1 and V2, but the device had an **unversioned** schema (V0)
3. SwiftData couldn't recognize the existing database version

## Solution Implemented

We created a **3-version migration path**:

### Schema V0 (Original Unversioned SwiftData + Legacy JSON Import)
- **What it is**: Represents the first SwiftData schema on your device (unversioned)
- **Characteristics**:
  - No version identifier (`versionIdentifier = nil`)
  - No `@Attribute(.unique)` constraints
  - Basic SDAppSettings (without permission tracking fields)
  - Models: SDEntryV0, SDIntakeTypeV0, SDGoalV0, SDAppSettingsV0
- **Legacy Data Import**: 
  - If SwiftData is empty, automatically imports from old JSON files:
    - `CommonEntry` → from AppGroupStorage JSON files
    - `IntakeType` → from intakeTypes.json in App Group
    - `CommonGoal` → from goalsstore.json in Documents
    - Settings → from UserDefaults

### Schema V1 (With Unique Constraints)
- **Migration**: V0 → V1 (lightweight automatic migration)
- **Changes**:
  - Added `@Attribute(.unique)` to ID fields
  - Version identifier: `Schema.Version(1, 0, 0)`
  - Models: SDEntryV1, SDIntakeTypeV1, SDGoalV1, SDAppSettingsV1

### Schema V2 (CloudKit Compatible - Current)
- **Migration**: V1 → V2 (custom migration)
- **Changes**:
  - Removed `@Attribute(.unique)` (CloudKit doesn't support unique constraints)
  - Added new permission tracking fields to SDAppSettings:
    - `iCloudAvailable`
    - `cloudKitAvailable`
    - `documentsAccessible`
    - `lastPermissionCheck`
  - Version identifier: `Schema.Version(2, 0, 0)`
  - Models: SDEntry, SDIntakeType, SDGoal, SDAppSettings (current versions)

## Migration Stages

### Stage 1: V0 → V1
```swift
MigrationStage.custom(
    fromVersion: KeepTrackSchemaV0.self,
    toVersion: KeepTrackSchemaV1.self,
    ...
)
```
- **Type**: Custom (with legacy JSON import)
- **What happens**: 
  1. SwiftData adds unique constraints to existing data
  2. Checks if SwiftData is empty
  3. If empty, imports legacy data from JSON files:
     - CommonEntry from AppGroupStorage
     - IntakeType from intakeTypes.json
     - CommonGoal from goalsstore.json
     - Settings from UserDefaults
  4. All your historical data is preserved!

### Stage 2: V1 → V2
```swift
MigrationStage.custom(
    fromVersion: KeepTrackSchemaV1.self,
    toVersion: KeepTrackSchemaV2.self,
    ...
)
```
- **Type**: Custom
- **What happens**:
  1. Removes unique constraints
  2. Adds new SDAppSettings fields with default values
  3. Updates `modifiedAt` timestamp on all settings
  4. Validates data integrity
  5. Logs migration results

## What Happens When You Run the App

1. **First Launch After Update**:
   - SwiftData detects your device has V0 (unversioned) schema
   - Runs V0 → V1 migration (lightweight, very fast)
   - Runs V1 → V2 migration (custom, with logging)
   - You'll see migration logs in console:
     ```
     🔄 Starting migration from V1 to V2
        - Removing unique constraints (CloudKit compatible)
        - Adding new permission tracking fields to SDAppSettings
     ✅ Migration from V1 to V2 completed successfully
     📊 Migration results:
        - Entries: [count]
        - Intake Types: [count]
        - Goals: [count]
        - Settings: [count]
     ```

2. **All Your Data Is Preserved**:
   - All entries, intake types, goals, and settings migrate automatically
   - No data loss
   - Relationships maintained

3. **After Migration**:
   - App uses V2 schema
   - CloudKit sync can work properly (no unique constraints)
   - Permission tracking fields available in SDAppSettings

## Files Modified

1. **ManagersSwiftDataSchemaMigration.swift**
   - Added KeepTrackSchemaV0 with unversioned models
   - Updated migration plan to include V0 → V1 → V2
   - Enhanced V1 → V2 migration to handle new SDAppSettings fields

2. **ManagersSwiftDataManager.swift**
   - Re-enabled versioned schema and migration plan
   - Improved error logging
   - Uses `Schema(versionedSchema: KeepTrackSchemaV2.self)`

## Testing the Migration

Run your app on your device and watch the console. You should see:

1. ✅ Migration logs indicating successful V0 → V1 → V2 migration
2. ✅ No more "unknown model version" errors
3. ✅ CloudKit initialization working (if properly configured)
4. ✅ All your existing data intact

## Troubleshooting

If you still get errors:

1. **Check Console Logs**: Look for migration errors with detailed information
2. **Verify Model Matches**: Make sure V0 models match what was actually on your device
3. **Check App Group**: Ensure App Group identifier is correct
4. **Verify CloudKit**: Check that CloudKit entitlements are properly configured

## Future Schema Changes

When you need to add V3 in the future:

1. Create `KeepTrackSchemaV3` enum
2. Add it to `schemas` array in migration plan
3. Create migration stage `migrateV2toV3`
4. Add the stage to `stages` array
5. Update `SwiftDataManager` to use V3 as current schema

Example:
```swift
static var schemas: [any VersionedSchema.Type] {
    [
        KeepTrackSchemaV0.self,
        KeepTrackSchemaV1.self,
        KeepTrackSchemaV2.self,
        KeepTrackSchemaV3.self  // New version
    ]
}
```

---

**Date**: January 12, 2026
**Migration Path**: V0 (unversioned) → V1 (unique constraints) → V2 (CloudKit compatible)
**Status**: ✅ Ready for testing
