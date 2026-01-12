//
//  BackupManagementView.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import SwiftUI
import SwiftData

/// Enhanced backup management view with quick actions
struct BackupManagementView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var settings: [SDAppSettings]
    @Query private var entries: [SDEntry]
    @Query private var intakeTypes: [SDIntakeType]
    @Query private var goals: [SDGoal]
    
    @State private var showingExportPicker = false
    @State private var showingImportPicker = false
    @State private var isProcessing = false
    @State private var alertMessage: AlertMessage?
    
    var appSettings: SDAppSettings? {
        settings.first
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Quick Actions
            VStack(spacing: 12) {
                quickActionButton(
                    title: "Export Backup",
                    subtitle: "Save your data to a file",
                    icon: "square.and.arrow.up.fill",
                    color: .blue
                ) {
                    showingExportPicker = true
                }
                
                quickActionButton(
                    title: "Import Backup",
                    subtitle: "Restore from a backup file",
                    icon: "square.and.arrow.down.fill",
                    color: .green
                ) {
                    showingImportPicker = true
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Quick Backup")
        .navigationBarTitleDisplayMode(.inline)
        .fileExporter(
            isPresented: $showingExportPicker,
            document: BackupDocument(data: Data()),
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
        .overlay {
            if isProcessing {
                ProgressView("Processing...")
                    .padding(20)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    @ViewBuilder
    private func quickActionButton(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color.gradient)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return formatter.string(from: Date())
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        Task {
            do {
                isProcessing = true
                defer { isProcessing = false }
                
                let url = try result.get()
                let migrationManager = DataMigrationManager(modelContext: modelContext)
                
                try await migrationManager.exportBackup(to: url)
                
                // Update last backup date
                if let appSettings = appSettings {
                    appSettings.lastBackupDate = Date()
                    try modelContext.save()
                }
                
                alertMessage = AlertMessage(
                    title: "Success",
                    message: "Backup exported successfully!"
                )
            } catch {
                alertMessage = AlertMessage(
                    title: "Export Failed",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        Task {
            do {
                isProcessing = true
                defer { isProcessing = false }
                
                let urls = try result.get()
                guard let url = urls.first else { return }
                
                let migrationManager = DataMigrationManager(modelContext: modelContext)
                try await migrationManager.importBackup(from: url, mergeStrategy: .merge)
                
                alertMessage = AlertMessage(
                    title: "Success",
                    message: "Backup imported successfully!"
                )
            } catch {
                alertMessage = AlertMessage(
                    title: "Import Failed",
                    message: error.localizedDescription
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        BackupManagementView()
            .modelContainer(SwiftDataManager.shared.container)
    }
}
