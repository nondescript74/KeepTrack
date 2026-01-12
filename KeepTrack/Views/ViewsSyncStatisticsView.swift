//
//  SyncStatisticsView.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import SwiftUI
import SwiftData

/// Displays detailed sync and backup statistics
struct SyncStatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query private var entries: [SDEntry]
    @Query private var intakeTypes: [SDIntakeType]
    @Query private var goals: [SDGoal]
    @Query private var settings: [SDAppSettings]
    
    var appSettings: SDAppSettings? {
        settings.first
    }
    
    var totalDataSize: String {
        let entrySize = entries.count * 200 // Rough estimate in bytes
        let typeSize = intakeTypes.count * 100
        let goalSize = goals.count * 150
        let total = entrySize + typeSize + goalSize
        return ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .file)
    }
    
    var body: some View {
        List {
            // Overview Section
            Section("Data Overview") {
                dataRow(
                    title: "Total Entries",
                    value: "\(entries.count)",
                    icon: "list.bullet.clipboard.fill",
                    color: .blue
                )
                
                dataRow(
                    title: "Intake Types",
                    value: "\(intakeTypes.count)",
                    icon: "pills.fill",
                    color: .green
                )
                
                dataRow(
                    title: "Active Goals",
                    value: "\(goals.filter { $0.isActive }.count)",
                    icon: "target",
                    color: .orange
                )
                
                dataRow(
                    title: "Estimated Size",
                    value: totalDataSize,
                    icon: "internaldrive.fill",
                    color: .purple
                )
            }
            
            // Timeline Section
            if !entries.isEmpty {
                Section("Timeline") {
                    if let firstEntry = entries.min(by: { $0.date < $1.date }) {
                        HStack {
                            Label("First Entry", systemImage: "calendar.badge.plus")
                            Spacer()
                            Text(firstEntry.date, style: .date)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let lastEntry = entries.max(by: { $0.date < $1.date }) {
                        HStack {
                            Label("Latest Entry", systemImage: "calendar.badge.clock")
                            Spacer()
                            Text(lastEntry.date, style: .relative)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    let dayCount = Calendar.current.dateComponents(
                        [.day],
                        from: entries.min(by: { $0.date < $1.date })?.date ?? Date(),
                        to: Date()
                    ).day ?? 0
                    
                    HStack {
                        Label("Tracking Duration", systemImage: "hourglass")
                        Spacer()
                        Text("\(dayCount) days")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Backup History Section
            Section("Backup History") {
                if let lastBackup = appSettings?.lastBackupDate {
                    HStack {
                        Label("Last Manual Backup", systemImage: "clock.arrow.circlepath")
                        Spacer()
                        Text(lastBackup, style: .relative)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack {
                        Label("Last Manual Backup", systemImage: "clock.arrow.circlepath")
                        Spacer()
                        Text("Never")
                            .foregroundStyle(.tertiary)
                    }
                }
                
                if appSettings?.cloudSyncEnabled == true {
                    HStack {
                        Label("iCloud Sync", systemImage: "icloud.fill")
                        Spacer()
                        Text("Active")
                            .foregroundStyle(.green)
                    }
                } else {
                    HStack {
                        Label("iCloud Sync", systemImage: "icloud.slash.fill")
                        Spacer()
                        Text("Disabled")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // This Week Section
            Section("This Week") {
                let thisWeekEntries = entries.filter { entry in
                    Calendar.current.isDate(entry.date, equalTo: Date(), toGranularity: .weekOfYear)
                }
                
                HStack {
                    Label("Entries This Week", systemImage: "calendar.badge.checkmark")
                    Spacer()
                    Text("\(thisWeekEntries.count)")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                
                let uniqueThisWeek = Set(thisWeekEntries.map { $0.name }).count
                HStack {
                    Label("Unique Items", systemImage: "checkmark.square")
                    Spacer()
                    Text("\(uniqueThisWeek)")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .navigationTitle("Statistics")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    @ViewBuilder
    private func dataRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color.gradient)
                .frame(width: 28)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
                .monospacedDigit()
        }
    }
}

#Preview {
    NavigationStack {
        SyncStatisticsView()
            .modelContainer(SwiftDataManager.shared.container)
    }
}
