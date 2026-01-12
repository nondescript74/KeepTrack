# SwiftData Backup & Restore System

## Overview

KeepTrack now uses **SwiftData** with **CloudKit sync** to automatically backup and sync your data across all your devices. This provides seamless cross-device synchronization and robust data persistence.

## Features

### 🔄 Automatic iCloud Sync
- All your data automatically syncs across iPhone, iPad, and Mac
- Changes sync in real-time when online
- Offline changes sync when connection is restored
- Uses your iCloud account (no additional setup required)

### 💾 Manual Backup & Restore
- Export your data to a JSON file for safekeeping
- Import data from a previous backup
- Share backups between devices or users
- Merge or replace data when importing

### 🔐 Privacy & Security
- All data stays in your iCloud private database
- End-to-end encrypted by Apple
- No third-party servers involved
- You control your data

## Architecture

### SwiftData Models

1. **SDEntry** - Tracks individual intake entries
2. **SDIntakeType** - Defines types of medications/supplements
3. **SDGoal** - Stores user goals and reminders
4. **SDAppSettings** - Stores app preferences and settings

All models include:
- Unique IDs for conflict resolution
- CloudKit sync support
- Backward compatibility with existing JSON storage

### Key Components

#### SwiftDataManager
Singleton that manages the SwiftData container with CloudKit configuration.

```swift
let manager = SwiftDataManager.shared
let context = manager.mainContext
```

#### DataMigrationManager
Handles one-time migration from JSON to SwiftData and backup/restore operations.

```swift
let migrationManager = DataMigrationManager(modelContext: context)
try await migrationManager.migrateAllData()
```

#### SwiftDataStore
Drop-in replacement for CommonStore that uses SwiftData backend.

```swift
let store = await SwiftDataStore.loadStore()
await store.addEntry(entry: myEntry)
```

## Usage

### Accessing Backup & Restore

1. Open the app
2. Navigate to Settings (or wherever you add the link)
3. Tap "Backup & Restore"
4. View your sync status and data statistics

### Exporting a Backup

1. In Backup & Restore view, tap "Export Backup"
2. Choose a location to save the JSON file
3. The file will be named with the current date/time
4. Save to Files app, AirDrop, or cloud storage

### Importing a Backup

1. In Backup & Restore view, tap "Import Backup"
2. Select a previously exported JSON file
3. Choose import strategy:
   - **Replace All Data**: Deletes existing data, imports backup
   - **Merge with Existing**: Keeps existing data, adds new items from backup
4. Confirm the import

### Migration

The app automatically migrates your existing JSON data to SwiftData on first launch after updating. This happens once and preserves all your data.

To manually trigger migration (for debugging):
1. Go to Backup & Restore → Advanced → Migration Tools
2. Tap "Run Migration"

## Configuration

### CloudKit Container

The app uses the following CloudKit container:
- **Container ID**: `iCloud.com.headydiscy.KeepTrack`
- **Database**: Private (user-specific)
- **App Group**: `group.com.headydiscy.KeepTrack`

### Required Capabilities

Make sure these are enabled in your Xcode project:

1. **iCloud**
   - CloudKit
   - Use default container: `iCloud.com.headydiscy.KeepTrack`

2. **App Groups**
   - `group.com.headydiscy.KeepTrack`

3. **Background Modes** (for sync)
   - Remote notifications

### Entitlements File

Ensure your `KeepTrack.entitlements` contains:

```xml
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
```

## Backward Compatibility

The system maintains full backward compatibility:

- **Existing JSON files** are preserved
- **CommonStore** continues to work
- **Gradual migration** to SwiftData happens automatically
- You can use both systems during transition

## Data Flow

```
User Action
    ↓
SwiftDataStore (SwiftData API)
    ↓
ModelContext (SwiftData)
    ↓
ModelContainer (Local Storage + CloudKit)
    ↓
iCloud Private Database
    ↓
Other User Devices
```

## Troubleshooting

### Sync Not Working

1. Check iCloud account is signed in (Settings → [Your Name])
2. Verify iCloud Drive is enabled
3. Check internet connection
4. Force quit and restart the app

### Migration Issues

1. Go to Backup & Restore → Advanced → Migration Tools
2. Check migration status
3. Try "Reset Migration Flag" and restart app
4. If problems persist, export a backup before resetting

### Data Conflicts

SwiftData automatically resolves most conflicts using:
- Unique IDs to identify records
- Timestamps to determine newest version
- CloudKit's built-in conflict resolution

## API Reference

### Adding Entries (SwiftData)

```swift
@Environment(\.modelContext) private var modelContext

func logIntake() async {
    let entry = SDEntry(
        date: Date(),
        units: "mg",
        amount: 5.0,
        name: "Amlodipine",
        goalMet: true
    )
    modelContext.insert(entry)
    try? modelContext.save()
}
```

### Querying Entries

```swift
@Query(sort: \SDEntry.date, order: .reverse) 
private var allEntries: [SDEntry]

@Query(filter: #Predicate<SDEntry> { entry in
    Calendar.current.isDateInToday(entry.date)
})
private var todaysEntries: [SDEntry]
```

### Using SwiftDataStore (wrapper)

```swift
let store = await SwiftDataStore.loadStore()

// Add entry
await store.addEntry(entry: CommonEntry(...))

// Get today's entries
let today = store.getTodaysIntake()

// Query by date range
let entries = await store.getEntries(
    from: startDate, 
    to: endDate
)
```

## Testing

The system includes comprehensive tests:

```swift
import Testing
import SwiftData

@Suite("Backup & Restore Tests")
struct BackupRestoreTests {
    @Test("Export backup creates valid JSON")
    func testExportBackup() async throws {
        // Test implementation
    }
    
    @Test("Import backup restores data")
    func testImportBackup() async throws {
        // Test implementation
    }
}
```

## Future Enhancements

- [ ] Automatic scheduled backups
- [ ] Backup encryption with password
- [ ] Backup to third-party cloud services
- [ ] Data export to CSV/Excel
- [ ] Selective backup (choose what to include)
- [ ] Backup versioning and history

## Support

If you encounter issues:
1. Export a manual backup first (as safeguard)
2. Check the Console app for logs (filter by "KeepTrack")
3. Try the migration tools in Advanced settings
4. Contact support with log details

---

**Version**: 1.0  
**Last Updated**: January 11, 2026
