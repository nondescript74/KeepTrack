//
//  BackupRestoreView.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct BackupRestoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var showingExportPicker = false
    @State private var showingImportPicker = false
    @State private var showingMergeOptions = false
    @State private var selectedMergeStrategy: BackupMergeStrategy = .replace
    @State private var alertMessage: AlertMessage?
    @State private var cloudSyncStatus: CloudSyncStatus = .unknown
    @State private var backupDocumentToExport: BackupDocument?
    
    // Stats
    @Query private var entries: [SDEntry]
    @Query private var intakeTypes: [SDIntakeType]
    @Query private var goals: [SDGoal]
    @Query private var settings: [SDAppSettings]
    
    var body: some View {
        NavigationStack {
            List {
                // Cloud Sync Section
                Section {
                    cloudSyncStatusRow
                    
                    if let lastBackup = settings.first?.lastBackupDate {
                        HStack {
                            Label("Last Backup", systemImage: "clock")
                            Spacer()
                            Text(lastBackup, style: .relative)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("iCloud Sync")
                } footer: {
                    Text("Your data automatically syncs across all your devices using iCloud.")
                }
                
                // Data Summary
                Section("Your Data") {
                    dataStatRow(title: "Entries", count: entries.count, icon: "list.bullet")
                    dataStatRow(title: "Intake Types", count: intakeTypes.count, icon: "pills")
                    dataStatRow(title: "Goals", count: goals.count, icon: "target")
                }
                
                // Backup Actions
                Section {
                    Button {
                        Task {
                            await prepareExport()
                        }
                    } label: {
                        Label("Export Backup", systemImage: "square.and.arrow.up")
                    }
                    .disabled(isExporting)
                    
                    Button {
                        showingImportPicker = true
                    } label: {
                        Label("Import Backup", systemImage: "square.and.arrow.down")
                    }
                    
                    NavigationLink {
                        BackupHistoryView()
                    } label: {
                        Label("Backup History", systemImage: "clock.arrow.circlepath")
                    }
                } header: {
                    Text("Manual Backup")
                } footer: {
                    Text("Create a backup file to save locally or share. You can restore from a backup file at any time. View your automatic backup history.")
                }
                
                // Advanced
                Section("Advanced") {
                    NavigationLink {
                        MigrationDebugView()
                    } label: {
                        Label("Migration Tools", systemImage: "wrench.and.screwdriver")
                    }
                }
            }
            .navigationTitle("Backup & Restore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .fileExporter(
                isPresented: $showingExportPicker,
                document: backupDocumentToExport,
                contentType: .json,
                defaultFilename: "KeepTrack-Backup-\(formattedDate()).json"
            ) { result in
                handleExportResult(result)
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImportResult(result)
            }
            .alert(item: $alertMessage) { message in
                Alert(
                    title: Text(message.title),
                    message: Text(message.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .confirmationDialog("Import Strategy", isPresented: $showingMergeOptions) {
                Button("Replace All Data") {
                    selectedMergeStrategy = .replace
                    performImport()
                }
                Button("Merge with Existing") {
                    selectedMergeStrategy = .merge
                    performImport()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Choose how to handle the imported data")
            }
            .task {
                await checkCloudSyncStatus()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var cloudSyncStatusRow: some View {
        HStack {
            Label("iCloud", systemImage: "icloud")
            Spacer()
            Group {
                switch cloudSyncStatus {
                case .syncing:
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Syncing")
                    }
                case .synced:
                    Label("Synced", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                case .error:
                    Label("Error", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                case .disabled:
                    Text("Disabled")
                        .foregroundStyle(.secondary)
                case .unknown:
                    Text("Unknown")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.caption)
        }
    }
    
    private func dataStatRow(title: String, count: Int, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text("\(count)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
    
    // MARK: - Helper Methods
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return formatter.string(from: Date())
    }
    
    private func prepareExport() async {
        do {
            isExporting = true
            defer { isExporting = false }
            
            let migrationManager = DataMigrationManager(modelContext: modelContext)
            
            // Create a temporary URL to export the data
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp-backup.json")
            
            // Export to temporary location
            try await migrationManager.exportBackup(to: tempURL)
            
            // Read the data
            let data = try Data(contentsOf: tempURL)
            
            // Clean up temp file
            try? FileManager.default.removeItem(at: tempURL)
            
            // Set the document with actual data
            backupDocumentToExport = BackupDocument(data: data)
            
            // Now show the file picker
            showingExportPicker = true
            
        } catch {
            alertMessage = AlertMessage(
                title: "Export Failed",
                message: "Failed to prepare backup: \(error.localizedDescription)"
            )
        }
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        Task {
            do {
                let url = try result.get()
                
                // Update last backup date
                if let appSettings = settings.first {
                    appSettings.lastBackupDate = Date()
                    try modelContext.save()
                }
                
                alertMessage = AlertMessage(
                    title: "Success",
                    message: "Backup exported successfully to \(url.lastPathComponent)"
                )
            } catch {
                alertMessage = AlertMessage(
                    title: "Export Failed",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    @State private var importURL: URL?
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            guard let url = urls.first else { return }
            
            importURL = url
            showingMergeOptions = true
        } catch {
            alertMessage = AlertMessage(
                title: "Import Failed",
                message: error.localizedDescription
            )
        }
    }
    
    private func performImport() {
        guard let url = importURL else { return }
        
        Task {
            do {
                isImporting = true
                defer { isImporting = false }
                
                let migrationManager = DataMigrationManager(modelContext: modelContext)
                try await migrationManager.importBackup(from: url, mergeStrategy: selectedMergeStrategy)
                
                alertMessage = AlertMessage(
                    title: "Success",
                    message: "Backup imported successfully"
                )
            } catch {
                alertMessage = AlertMessage(
                    title: "Import Failed",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    private func checkCloudSyncStatus() async {
        // In a real implementation, you would check CloudKit status
        // For now, we'll assume it's synced if settings have cloudSyncEnabled
        if let appSettings = settings.first, appSettings.cloudSyncEnabled {
            cloudSyncStatus = .synced
        } else {
            cloudSyncStatus = .disabled
        }
    }
}

// MARK: - Supporting Types

struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

enum CloudSyncStatus {
    case syncing
    case synced
    case error
    case disabled
    case unknown
}

// MARK: - Document Type

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Preview

#Preview {
    BackupRestoreView()
        .modelContainer(SwiftDataManager.shared.container)
}
