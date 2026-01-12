//
//  MigrationDebugView.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import SwiftUI
import SwiftData

struct MigrationDebugView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var migrationStatus: String = "Checking..."
    @State private var schemaVersion: String = "Checking..."
    @State private var lastMigrationDate: String = "Never"
    @State private var dataCount: (entries: Int, types: Int, goals: Int, settings: Int) = (0, 0, 0, 0)
    @State private var isProcessing = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var validationReport: MigrationValidationReport?
    
    var body: some View {
        List {
            Section("Schema Status") {
                HStack {
                    Text("Current Schema")
                    Spacer()
                    Text(schemaVersion)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Last Migration")
                    Spacer()
                    Text(lastMigrationDate)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("JSON Migration")
                    Spacer()
                    Text(migrationStatus)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Data Count") {
                HStack {
                    Text("Entries")
                    Spacer()
                    Text("\(dataCount.entries)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Intake Types")
                    Spacer()
                    Text("\(dataCount.types)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Goals")
                    Spacer()
                    Text("\(dataCount.goals)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Settings")
                    Spacer()
                    Text("\(dataCount.settings)")
                        .foregroundStyle(.secondary)
                }
            }
            
            if let report = validationReport {
                Section("Validation") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(report.isValid ? "✅ Valid" : "⚠️ Issues Found")
                            .foregroundStyle(report.isValid ? .green : .orange)
                    }
                    
                    if report.hasDuplicates {
                        Label("Duplicate IDs detected", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }
            
            Section("Actions") {
                Button {
                    validateData()
                } label: {
                    Label("Validate Data", systemImage: "checkmark.shield")
                }
                .disabled(isProcessing)
                
                Button {
                    performMigration()
                } label: {
                    Label("Run JSON Migration", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(isProcessing)
                
                Button {
                    createBackup()
                } label: {
                    Label("Create Backup", systemImage: "square.and.arrow.down")
                }
                .disabled(isProcessing)
                
                Button(role: .destructive) {
                    resetMigration()
                } label: {
                    Label("Reset Migration Flag", systemImage: "arrow.counterclockwise")
                }
                .disabled(isProcessing)
            }
            
            Section {
                Text("Use these tools to troubleshoot migration issues. The schema migration from V1 to V2 happens automatically.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Migration Tools")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .overlay {
            if isProcessing {
                ProgressView("Processing...")
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .alert("Migration", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .task {
            await refreshStatus()
        }
    }
    
    private func refreshStatus() async {
        let manager = DataMigrationManager(modelContext: modelContext)
        let versionChecker = SchemaVersionChecker.shared
        
        migrationStatus = manager.isMigrationCompleted ? "Completed" : "Not Started"
        schemaVersion = versionChecker.currentVersion ?? "2.0.0 (current)"
        
        if let date = versionChecker.lastMigrationDate {
            lastMigrationDate = date.formatted(date: .abbreviated, time: .shortened)
        } else {
            lastMigrationDate = "Never"
        }
        
        // Count data
        do {
            let entries = try modelContext.fetchCount(FetchDescriptor<SDEntry>())
            let types = try modelContext.fetchCount(FetchDescriptor<SDIntakeType>())
            let goals = try modelContext.fetchCount(FetchDescriptor<SDGoal>())
            let settings = try modelContext.fetchCount(FetchDescriptor<SDAppSettings>())
            dataCount = (entries, types, goals, settings)
        } catch {
            print("Error counting data: \(error)")
        }
    }
    
    private func validateData() {
        Task {
            isProcessing = true
            defer { isProcessing = false }
            
            do {
                let versionChecker = SchemaVersionChecker.shared
                let report = try versionChecker.validateMigration(context: modelContext)
                validationReport = report
                
                alertMessage = report.isValid ? 
                    "✅ Data validation passed!\n\nAll data is valid and consistent." :
                    "⚠️ Validation found issues\n\n\(report.description)"
            } catch {
                alertMessage = "Validation error: \(error.localizedDescription)"
            }
            
            showingAlert = true
        }
    }
    
    private func createBackup() {
        Task {
            isProcessing = true
            defer { isProcessing = false }
            
            do {
                let versionChecker = SchemaVersionChecker.shared
                let backupURL = try versionChecker.createPreMigrationBackup()
                
                alertMessage = "Backup created successfully at:\n\(backupURL.lastPathComponent)"
            } catch {
                alertMessage = "Backup failed: \(error.localizedDescription)"
            }
            
            showingAlert = true
        }
    }
    
    private func performMigration() {
        Task {
            isProcessing = true
            defer { isProcessing = false }
            
            do {
                let manager = DataMigrationManager(modelContext: modelContext)
                try await manager.migrateAllData()
                
                alertMessage = "Migration completed successfully!"
                await refreshStatus()
            } catch {
                alertMessage = "Migration failed: \(error.localizedDescription)"
            }
            
            showingAlert = true
        }
    }
    
    private func resetMigration() {
        let manager = DataMigrationManager(modelContext: modelContext)
        manager.resetMigration()
        
        Task {
            alertMessage = "Migration flag reset. Migration will run on next app launch."
            await refreshStatus()
            showingAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        MigrationDebugView()
            .modelContainer(SwiftDataManager.shared.container)
    }
}
