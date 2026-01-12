# Backup Export Fix

## Problem
The backup export feature was failing because the `.fileExporter` modifier was being given an empty `BackupDocument(data: Data())` when presented. The actual data export was happening **after** the file picker was shown, which is too late.

## Root Cause
SwiftUI's `.fileExporter` modifier requires the document to contain the actual data **before** it's presented to the user. The completion handler only receives the URL where the user wants to save the file - it's not meant for generating the data.

## Solution
The fix involves three changes:

### 1. Add State Variable for Document
```swift
@State private var backupDocumentToExport: BackupDocument?
```

### 2. Prepare Data Before Showing File Picker
Changed the Export button to call a new `prepareExport()` method that:
- Exports data to a temporary file
- Reads the data into memory
- Creates a `BackupDocument` with the actual data
- Cleans up the temporary file
- **Then** shows the file picker

```swift
Button {
    Task {
        await prepareExport()
    }
} label: {
    Label("Export Backup", systemImage: "square.and.arrow.up")
}
.disabled(isExporting)
```

### 3. Update FileExporter Modifier
```swift
.fileExporter(
    isPresented: $showingExportPicker,
    document: backupDocumentToExport,  // Now contains actual data!
    contentType: .json,
    defaultFilename: "KeepTrack-Backup-\(formattedDate()).json"
) { result in
    handleExportResult(result)
}
```

## Flow Comparison

### Before (Broken)
1. User taps Export
2. File picker shows immediately with empty data
3. User selects location
4. App tries to export data → **Error!**

### After (Fixed)
1. User taps Export
2. App prepares backup data
3. File picker shows with actual data
4. User selects location
5. System saves the file → **Success!**

## Additional Benefits
- Better user feedback with the `isExporting` state
- Temporary file is cleaned up properly
- Errors during data preparation are caught before showing the file picker
- Last backup date is only updated on successful save

## Testing
To test the fix:
1. Open the app
2. Navigate to Backup & Restore
3. Tap "Export Backup"
4. Wait for data to be prepared (button will be disabled)
5. Choose a location in the file picker
6. Verify the file is saved successfully
7. Check that the file contains valid JSON data
