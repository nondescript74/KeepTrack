//
//  SettingsView.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 12/24/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showDiagnosticLog = false
    @State private var showReminderTestingHelp = false
    @State private var showBackupRestore = false
    
    @StateObject private var autoBackupScheduler = AutoBackupScheduler.shared
    
    // Query settings from SwiftData
    @Query private var settings: [SDAppSettings]
    
    // Local state for toggles
    @State private var notificationsEnabled = true
    @State private var cloudSyncEnabled = true
    @State private var autoBackupEnabled = false
    
    var appSettings: SDAppSettings? {
        settings.first
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Backup Status Card
                Section {
                    BackupStatusCard()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                
                // Quick Backup Actions
                Section {
                    BackupQuickActionsView()
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                } header: {
                    Text("Quick Actions")
                }
                
                // Data & Sync Section
                Section {
                    NavigationLink {
                        BackupRestoreView()
                    } label: {
                        HStack {
                            Label("Backup & Restore", systemImage: "icloud.and.arrow.up.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    
                    NavigationLink {
                        SyncStatisticsView()
                    } label: {
                        HStack {
                            Label("Sync Statistics", systemImage: "chart.bar.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                } header: {
                    Text("Data & Sync")
                } footer: {
                    Text("Backup your data and sync across devices using iCloud. View detailed statistics about your data.")
                }
                
                // Preferences Section
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    .onChange(of: notificationsEnabled) { _, newValue in
                        updateNotificationsSetting(newValue)
                    }
                    
                    Toggle(isOn: $cloudSyncEnabled) {
                        Label("iCloud Sync", systemImage: "icloud.fill")
                    }
                    .onChange(of: cloudSyncEnabled) { _, newValue in
                        updateCloudSyncSetting(newValue)
                    }
                    
                    Toggle(isOn: $autoBackupEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Auto Backup", systemImage: "clock.arrow.circlepath")
                            if autoBackupEnabled, let nextBackup = autoBackupScheduler.nextScheduledBackup {
                                Text("Next backup: \(nextBackup, style: .relative)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onChange(of: autoBackupEnabled) { _, newValue in
                        updateAutoBackupSetting(newValue)
                    }
                } header: {
                    Text("Preferences")
                } footer: {
                    Text("Enable automatic backups to ensure your data is always safe.")
                }
                
                // Data Statistics Section
                Section("Data Statistics") {
                    DataStatsRow()
                }
                
                // Help & Support Section
                Section("Help & Support") {
                    Button {
                        showReminderTestingHelp = true
                    } label: {
                        HStack {
                            Label("Reminder Testing Guide", systemImage: "bell.badge.circle")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button {
                        showDiagnosticLog = true
                    } label: {
                        HStack {
                            Label("Diagnostic Log", systemImage: "doc.text.magnifyingglass")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // App Information Section
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Storage")
                        Spacer()
                        Text("SwiftData + CloudKit")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showDiagnosticLog) {
                DiagnosticLogView()
            }
            .sheet(isPresented: $showReminderTestingHelp) {
                HelpView(topic: HelpContentManager.getHelpTopic(for: .reminderTesting))
            }
            .task {
                loadSettings()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadSettings() {
        if let settings = appSettings {
            notificationsEnabled = settings.notificationsEnabled
            cloudSyncEnabled = settings.cloudSyncEnabled
            autoBackupEnabled = settings.autoBackupEnabled
        } else {
            // Create default settings if none exist
            let newSettings = SDAppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
        }
    }
    
    private func updateNotificationsSetting(_ enabled: Bool) {
        guard let settings = appSettings else { return }
        settings.notificationsEnabled = enabled
        settings.modifiedAt = Date()
        try? modelContext.save()
    }
    
    private func updateCloudSyncSetting(_ enabled: Bool) {
        guard let settings = appSettings else { return }
        settings.cloudSyncEnabled = enabled
        settings.modifiedAt = Date()
        try? modelContext.save()
    }
    
    private func updateAutoBackupSetting(_ enabled: Bool) {
        guard let settings = appSettings else { return }
        settings.autoBackupEnabled = enabled
        settings.modifiedAt = Date()
        try? modelContext.save()
        
        // Schedule or cancel auto backup
        Task {
            if enabled {
                await autoBackupScheduler.scheduleAutoBackup()
            } else {
                autoBackupScheduler.cancelScheduledBackup()
            }
        }
    }
}

// MARK: - Data Statistics View

struct DataStatsRow: View {
    @Query private var entries: [SDEntry]
    @Query private var intakeTypes: [SDIntakeType]
    @Query private var goals: [SDGoal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            StatRow(title: "Entries", count: entries.count, icon: "list.bullet.clipboard")
            StatRow(title: "Intake Types", count: intakeTypes.count, icon: "pills.fill")
            StatRow(title: "Goals", count: goals.count, icon: "target")
            
            if !entries.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Text("First Entry")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let firstEntry = entries.min(by: { $0.date < $1.date }) {
                        Text(firstEntry.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func StatRow(title: String, count: Int, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(title)
            Spacer()
            Text("\(count)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .modelContainer(SwiftDataManager.shared.container)
}
