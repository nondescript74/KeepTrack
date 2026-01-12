//
//  BackupStatusCard.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import SwiftUI
import SwiftData

/// A visual card showing backup and sync status
struct BackupStatusCard: View {
    @Query private var settings: [SDAppSettings]
    @State private var cloudSyncStatus: CloudSyncStatus = .unknown
    
    var appSettings: SDAppSettings? {
        settings.first
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "icloud.fill")
                    .font(.title2)
                    .foregroundStyle(.blue.gradient)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("iCloud Sync")
                        .font(.headline)
                    statusText
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                statusIcon
            }
            
            Divider()
            
            // Details
            VStack(spacing: 8) {
                if let lastBackup = appSettings?.lastBackupDate {
                    HStack {
                        Label("Last Backup", systemImage: "clock")
                            .font(.caption)
                        Spacer()
                        Text(lastBackup, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if appSettings?.cloudSyncEnabled == true {
                    HStack {
                        Label("Auto Sync", systemImage: "arrow.triangle.2.circlepath")
                            .font(.caption)
                        Spacer()
                        Text("Enabled")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            await checkSyncStatus()
        }
    }
    
    @ViewBuilder
    private var statusText: some View {
        switch cloudSyncStatus {
        case .synced:
            Text("All data synced")
        case .syncing:
            Text("Syncing...")
        case .error:
            Text("Sync error")
        case .disabled:
            Text("Sync disabled")
        case .unknown:
            Text("Checking status...")
        }
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch cloudSyncStatus {
        case .synced:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title3)
        case .syncing:
            ProgressView()
        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.title3)
        case .disabled:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.gray)
                .font(.title3)
        case .unknown:
            Image(systemName: "questionmark.circle")
                .foregroundStyle(.secondary)
                .font(.title3)
        }
    }
    
    private func checkSyncStatus() async {
        // Simulate checking CloudKit status
        try? await Task.sleep(for: .milliseconds(500))
        
        if appSettings?.cloudSyncEnabled == true {
            cloudSyncStatus = .synced
        } else {
            cloudSyncStatus = .disabled
        }
    }
}

#Preview {
    BackupStatusCard()
        .modelContainer(SwiftDataManager.shared.container)
        .padding()
}
