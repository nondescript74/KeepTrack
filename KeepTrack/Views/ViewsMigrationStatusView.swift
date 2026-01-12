//
//  MigrationStatusView.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import SwiftUI
import SwiftData

/// Debug view to show migration status and data counts
struct MigrationStatusView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var entries: [SDEntry]
    @Query private var intakeTypes: [SDIntakeType]
    @Query private var goals: [SDGoal]
    @Query private var settings: [SDAppSettings]
    
    var body: some View {
        List {
            Section("Migration Status") {
                HStack {
                    Text("Schema Version")
                    Spacer()
                    Text("V2 (CloudKit Compatible)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("CloudKit Sync")
                    Spacer()
                    Text(SwiftDataManager.shared.isCloudKitEnabled ? "Enabled" : "Disabled")
                        .foregroundStyle(SwiftDataManager.shared.isCloudKitEnabled ? .green : .orange)
                }
            }
            
            Section("Data Counts") {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Entries")
                    Spacer()
                    Text("\(entries.count)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Image(systemName: "pills")
                    Text("Intake Types")
                    Spacer()
                    Text("\(intakeTypes.count)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Image(systemName: "target")
                    Text("Goals")
                    Spacer()
                    Text("\(goals.count)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Image(systemName: "gear")
                    Text("Settings")
                    Spacer()
                    Text("\(settings.count)")
                        .foregroundStyle(.secondary)
                }
            }
            
            if let firstSettings = settings.first {
                Section("Settings Details") {
                    HStack {
                        Text("Created At")
                        Spacer()
                        Text(firstSettings.createdAt, style: .date)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Modified At")
                        Spacer()
                        Text(firstSettings.modifiedAt, style: .date)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("iCloud Available")
                        Spacer()
                        Text(firstSettings.iCloudAvailable ? "Yes" : "No")
                            .foregroundStyle(firstSettings.iCloudAvailable ? .green : .secondary)
                    }
                    
                    HStack {
                        Text("CloudKit Available")
                        Spacer()
                        Text(firstSettings.cloudKitAvailable ? "Yes" : "No")
                            .foregroundStyle(firstSettings.cloudKitAvailable ? .green : .secondary)
                    }
                    
                    if let lastCheck = firstSettings.lastPermissionCheck {
                        HStack {
                            Text("Last Permission Check")
                            Spacer()
                            Text(lastCheck, style: .relative)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            Section("Model Container Info") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Container")
                        .font(.headline)
                    Text("Autosave: \(SwiftDataManager.shared.mainContext.autosaveEnabled ? "Enabled" : "Disabled")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Migration Status")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        MigrationStatusView()
            .modelContainer(SwiftDataManager.shared.container)
    }
}
