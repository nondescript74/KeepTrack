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
        #if os(macOS)
        NavigationSplitView {
            settingsContent
                .navigationSplitViewColumnWidth(min: 300, ideal: 350, max: 400)
        } detail: {
            Text("Select an option")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, idealWidth: 1000, minHeight: 600, idealHeight: 700)
        #else
        NavigationStack {
            settingsContent
        }
        #endif
    }
    
    @ViewBuilder
    private var settingsContent: some View {
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
            
            // System Status Section
            Section {
                PermissionStatusCardForSettings()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            } header: {
                Text("System Status")
            } footer: {
                Text("Check iCloud availability and storage permissions. These are required for sync and backups.")
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
        .navigationBarTitleDisplayModeAdaptive(.inline)
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .adaptiveConfirmation) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        #endif
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
    @Environment(\.modelContext) private var modelContext
    @State private var entryCount = 0
    @State private var intakeTypeCount = 0
    @State private var goalCount = 0
    @State private var firstEntryDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            StatRow(title: "Entries", count: entryCount, icon: "list.bullet.clipboard")
            StatRow(title: "Intake Types", count: intakeTypeCount, icon: "pills.fill")
            StatRow(title: "Goals", count: goalCount, icon: "target")
            
            if let firstDate = firstEntryDate {
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
                    Text(firstDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
        .task {
            await loadStats()
        }
    }
    
    private func loadStats() async {
        do {
            // Fetch counts manually
            let entries = try modelContext.fetch(FetchDescriptor<SDEntry>())
            let intakeTypes = try modelContext.fetch(FetchDescriptor<SDIntakeType>())
            let goals = try modelContext.fetch(FetchDescriptor<SDGoal>())
            
            entryCount = entries.count
            intakeTypeCount = intakeTypes.count
            goalCount = goals.count
            
            if let firstEntry = entries.min(by: { $0.date < $1.date }) {
                firstEntryDate = firstEntry.date
            }
            
            print("📊 Stats loaded: \(entryCount) entries, \(intakeTypeCount) types, \(goalCount) goals")
        } catch {
            print("❌ Error loading stats: \(error)")
        }
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
