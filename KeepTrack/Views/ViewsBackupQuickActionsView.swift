//
//  BackupQuickActionsView.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import SwiftUI
import SwiftData

/// Quick action buttons for backup operations in settings
struct BackupQuickActionsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var settings: [SDAppSettings]
    
    @State private var showingExportPicker = false
    @State private var isExporting = false
    @State private var alertMessage: AlertMessage?
    
    var appSettings: SDAppSettings? {
        settings.first
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Export Button
                Button {
                    showingExportPicker = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.title2)
                            .foregroundStyle(.blue.gradient)
                        
                        Text("Export")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(isExporting)
                
                // View Stats Button
                NavigationLink {
                    SyncStatisticsView()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                            .foregroundStyle(.green.gradient)
                        
                        Text("Statistics")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            
            // Last backup info
            if let lastBackup = appSettings?.lastBackupDate {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    Text("Last backup: \(lastBackup, style: .relative)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    Text("No manual backup yet")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .fileExporter(
            isPresented: $showingExportPicker,
            document: BackupDocument(data: Data()),
            contentType: .json,
            defaultFilename: "KeepTrack-Backup-\(formattedDate()).json"
        ) { result in
            handleExportResult(result)
        }
        .alert(item: $alertMessage) { message in
            Alert(
                title: Text(message.title),
                message: Text(message.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return formatter.string(from: Date())
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        Task {
            do {
                isExporting = true
                defer { isExporting = false }
                
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
}

#Preview {
    NavigationStack {
        List {
            Section {
                BackupQuickActionsView()
            } header: {
                Text("Quick Actions")
            }
        }
        .modelContainer(SwiftDataManager.shared.container)
    }
}
