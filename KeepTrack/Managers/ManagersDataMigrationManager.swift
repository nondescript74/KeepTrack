//
//  DataMigrationManager.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import SwiftData
import OSLog

/// Handles migration from JSON-based storage to SwiftData
@MainActor
final class DataMigrationManager {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "DataMigration")
    private let modelContext: ModelContext
    
    private static let migrationCompletedKey = "SwiftDataMigrationCompleted"
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Check if migration has already been completed
    var isMigrationCompleted: Bool {
        UserDefaults.standard.bool(forKey: Self.migrationCompletedKey)
    }
    
    /// Perform full migration from JSON to SwiftData
    func migrateAllData() async throws {
        guard !isMigrationCompleted else {
            logger.info("Migration already completed, skipping")
            return
        }
        
        logger.info("Starting data migration to SwiftData...")
        
        // Migrate entries
        try await migrateEntries()
        
        // Migrate intake types
        try await migrateIntakeTypes()
        
        // Migrate settings
        try await migrateSettings()
        
        // Mark migration as complete
        UserDefaults.standard.set(true, forKey: Self.migrationCompletedKey)
        logger.info("Data migration completed successfully")
    }
    
    /// Migrate entries from CommonStore to SwiftData
    private func migrateEntries() async throws {
        logger.info("Migrating entries...")
        
        let store = await CommonStore.loadStore()
        let entries = store.history
        
        logger.info("Found \(entries.count) entries to migrate")
        
        for commonEntry in entries {
            let sdEntry = SDEntry(from: commonEntry)
            modelContext.insert(sdEntry)
        }
        
        try modelContext.save()
        logger.info("Migrated \(entries.count) entries")
    }
    
    /// Migrate intake types from CurrentIntakeTypes to SwiftData
    private func migrateIntakeTypes() async throws {
        logger.info("Migrating intake types...")
        
        let currentTypes = CurrentIntakeTypes()
        await currentTypes.loadIntakeTypes()
        let types = currentTypes.intakeTypeArray
        
        logger.info("Found \(types.count) intake types to migrate")
        
        for intakeType in types {
            let sdType = SDIntakeType(from: intakeType)
            modelContext.insert(sdType)
        }
        
        try modelContext.save()
        logger.info("Migrated \(types.count) intake types")
    }
    
    /// Migrate settings from UserDefaults to SwiftData
    private func migrateSettings() async throws {
        logger.info("Migrating settings...")
        
        // Check if settings already exist
        let descriptor = FetchDescriptor<SDAppSettings>()
        let existingSettings = try modelContext.fetch(descriptor)
        
        if !existingSettings.isEmpty {
            logger.info("Settings already exist in SwiftData, skipping")
            return
        }
        
        // Create new settings from UserDefaults
        let settings = SDAppSettings()
        
        // Migrate license acceptance
        if let version = UserDefaults.standard.string(forKey: "AcceptedLicenseVersion") {
            settings.acceptedLicenseVersion = version
        }
        
        // Add other UserDefaults migrations here as needed
        
        modelContext.insert(settings)
        try modelContext.save()
        logger.info("Migrated settings")
    }
    
    /// Force re-migration (useful for testing or data recovery)
    func resetMigration() {
        UserDefaults.standard.removeObject(forKey: Self.migrationCompletedKey)
        logger.info("Migration reset - will run on next app launch")
    }
    
    /// Export SwiftData to backup file
    func exportBackup(to url: URL) async throws {
        logger.info("Exporting backup to \(url.path)")
        
        // Fetch all data
        let entries = try modelContext.fetch(FetchDescriptor<SDEntry>())
        let intakeTypes = try modelContext.fetch(FetchDescriptor<SDIntakeType>())
        let goals = try modelContext.fetch(FetchDescriptor<SDGoal>())
        let settings = try modelContext.fetch(FetchDescriptor<SDAppSettings>())
        
        // Convert SwiftData models to backup structures
        let backupEntries = entries.map { entry in
            CommonEntry(
                id: entry.id,
                date: entry.date,
                units: entry.units,
                amount: entry.amount,
                name: entry.name,
                goalMet: entry.goalMet
            )
        }
        
        let backupTypes = intakeTypes.map { type in
            IntakeType(
                id: type.id,
                name: type.name,
                unit: type.unit,
                amount: type.amount,
                descrip: type.descrip,
                frequency: type.frequency
            )
        }
        
        let backupGoals = goals.map { goal in
            CommonGoal(
                id: goal.id,
                name: goal.name,
                description: goal.goalDescription,
                dates: goal.dates,
                isActive: goal.isActive,
                isCompleted: goal.isCompleted,
                dosage: goal.dosage,
                units: goal.units,
                frequency: goal.frequency
            )
        }
        
        // Create backup structure
        let backup = BackupData(
            version: 1,
            exportDate: Date(),
            entries: backupEntries,
            intakeTypes: backupTypes,
            goals: backupGoals,
            settings: settings.first.map { BackupSettings(from: $0) }
        )
        
        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(backup)
        
        // Write to file
        try data.write(to: url, options: .atomic)
        
        logger.info("Backup exported successfully: \(entries.count) entries, \(intakeTypes.count) types, \(goals.count) goals")
    }
    
    /// Import backup from file
    func importBackup(from url: URL, mergeStrategy: BackupMergeStrategy = .replace) async throws {
        logger.info("Importing backup from \(url.path)")
        
        // Read and decode backup
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let backup = try decoder.decode(BackupData.self, from: data)
        
        logger.info("Backup version \(backup.version) from \(backup.exportDate)")
        
        switch mergeStrategy {
        case .replace:
            try await replaceAllData(with: backup)
        case .merge:
            try await mergeData(with: backup)
        }
        
        logger.info("Backup imported successfully")
    }
    
    /// Replace all existing data with backup
    private func replaceAllData(with backup: BackupData) async throws {
        // Delete existing data
        try modelContext.delete(model: SDEntry.self)
        try modelContext.delete(model: SDIntakeType.self)
        try modelContext.delete(model: SDGoal.self)
        try modelContext.delete(model: SDAppSettings.self)
        
        // Insert backup data
        for entry in backup.entries {
            modelContext.insert(SDEntry(from: entry))
        }
        
        for type in backup.intakeTypes {
            modelContext.insert(SDIntakeType(from: type))
        }
        
        for goal in backup.goals {
            modelContext.insert(SDGoal(from: goal))
        }
        
        if let settings = backup.settings {
            modelContext.insert(SDAppSettings(
                notificationsEnabled: settings.notificationsEnabled,
                preferredUnits: settings.preferredUnits,
                theme: settings.theme,
                autoBackupEnabled: settings.autoBackupEnabled,
                cloudSyncEnabled: settings.cloudSyncEnabled,
                acceptedLicenseVersion: settings.acceptedLicenseVersion
            ))
        }
        
        try modelContext.save()
    }
    
    /// Merge backup data with existing data
    private func mergeData(with backup: BackupData) async throws {
        // Fetch existing IDs
        let existingEntryIDs = Set(try modelContext.fetch(FetchDescriptor<SDEntry>()).map { $0.id })
        let existingTypeIDs = Set(try modelContext.fetch(FetchDescriptor<SDIntakeType>()).map { $0.id })
        let existingGoalIDs = Set(try modelContext.fetch(FetchDescriptor<SDGoal>()).map { $0.id })
        
        // Insert only new items
        for entry in backup.entries where !existingEntryIDs.contains(entry.id) {
            modelContext.insert(SDEntry(from: entry))
        }
        
        for type in backup.intakeTypes where !existingTypeIDs.contains(type.id) {
            modelContext.insert(SDIntakeType(from: type))
        }
        
        for goal in backup.goals where !existingGoalIDs.contains(goal.id) {
            modelContext.insert(SDGoal(from: goal))
        }
        
        try modelContext.save()
    }
}

// MARK: - Backup Data Structures

struct BackupData: Codable {
    let version: Int
    let exportDate: Date
    let entries: [CommonEntry]
    let intakeTypes: [IntakeType]
    let goals: [CommonGoal]
    let settings: BackupSettings?
}

struct BackupSettings: Codable {
    let notificationsEnabled: Bool
    let preferredUnits: String
    let theme: String
    let autoBackupEnabled: Bool
    let cloudSyncEnabled: Bool
    let acceptedLicenseVersion: String?
    
    init(from sdSettings: SDAppSettings) {
        self.notificationsEnabled = sdSettings.notificationsEnabled
        self.preferredUnits = sdSettings.preferredUnits
        self.theme = sdSettings.theme
        self.autoBackupEnabled = sdSettings.autoBackupEnabled
        self.cloudSyncEnabled = sdSettings.cloudSyncEnabled
        self.acceptedLicenseVersion = sdSettings.acceptedLicenseVersion
    }
}

enum BackupMergeStrategy {
    case replace  // Replace all existing data
    case merge    // Keep existing, add new items only
}
