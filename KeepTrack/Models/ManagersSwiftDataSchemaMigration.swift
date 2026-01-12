//
//  SwiftDataSchemaMigration.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import Foundation
import SwiftData
import OSLog

/// Schema migration plan for SwiftData model changes
enum KeepTrackSchemaMigrationPlan: SchemaMigrationPlan {
    
    // Define all schema versions
    static var schemas: [any VersionedSchema.Type] {
        [
            KeepTrackSchemaV0.self,  // Original schema before versioning (unversioned models)
            KeepTrackSchemaV1.self,  // Schema with @Attribute(.unique)
            KeepTrackSchemaV2.self   // Current schema without unique constraints (CloudKit compatible)
        ]
    }
    
    // Define migration stages
    static var stages: [MigrationStage] {
        [
            // Migration from V0 (unversioned) to V1
            migrateV0toV1,
            // Migration from V1 to V2
            migrateV1toV2
        ]
    }
    
    /// Migration from V0 (unversioned, original models) to V1
    /// Also imports data from legacy JSON files if they exist
    static let migrateV0toV1 = MigrationStage.custom(
        fromVersion: KeepTrackSchemaV0.self,
        toVersion: KeepTrackSchemaV1.self,
        willMigrate: { context in
            print("🔄 Starting migration from V0 to V1")
            print("   - Adding unique constraints")
            print("   - Checking for legacy JSON data to import")
        },
        didMigrate: { context in
            print("✅ Migration from V0 to V1 completed")
            
            // Import legacy JSON data if it exists and SwiftData is empty
            Task { @MainActor in
                await importLegacyJSONDataIfNeeded(context: context)
            }
        }
    )
    
    /// Import legacy JSON-based data into SwiftData if SwiftData is empty
    @MainActor
    private static func importLegacyJSONDataIfNeeded(context: ModelContext) async {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Migration")
        
        do {
            // Check if SwiftData already has entries
            let entryCount = try context.fetchCount(FetchDescriptor<KeepTrackSchemaV1.SDEntryV1>())
            
            if entryCount > 0 {
                logger.info("SwiftData already contains \(entryCount) entries, skipping JSON import")
                return
            }
            
            logger.info("📦 Importing legacy JSON data into SwiftData...")
            
            // Import entries from CommonStore (JSON files in App Group)
            let commonStore = await CommonStore.loadStore()
            if !commonStore.history.isEmpty {
                logger.info("Found \(commonStore.history.count) entries in CommonStore JSON")
                for entry in commonStore.history {
                    let sdEntry = KeepTrackSchemaV1.SDEntryV1(
                        id: entry.id,
                        date: entry.date,
                        units: entry.units,
                        amount: entry.amount,
                        name: entry.name,
                        goalMet: entry.goalMet
                    )
                    context.insert(sdEntry)
                }
                logger.info("✅ Imported \(commonStore.history.count) entries")
            }
            
            // Import intake types from CurrentIntakeTypes (JSON in App Group)
            let intakeTypes = CurrentIntakeTypes()
            await intakeTypes.loadIntakeTypes()
            if !intakeTypes.intakeTypeArray.isEmpty {
                logger.info("Found \(intakeTypes.intakeTypeArray.count) intake types in JSON")
                for type in intakeTypes.intakeTypeArray {
                    let sdType = KeepTrackSchemaV1.SDIntakeTypeV1(
                        id: type.id,
                        name: type.name,
                        unit: type.unit,
                        amount: type.amount,
                        descrip: type.descrip,
                        frequency: type.frequency
                    )
                    context.insert(sdType)
                }
                logger.info("✅ Imported \(intakeTypes.intakeTypeArray.count) intake types")
            }
            
            // Import goals from CommonGoals (JSON in Documents)
            let commonGoals = CommonGoals()
            if !commonGoals.goals.isEmpty {
                logger.info("Found \(commonGoals.goals.count) goals in JSON")
                for goal in commonGoals.goals {
                    let sdGoal = KeepTrackSchemaV1.SDGoalV1(
                        id: goal.id,
                        name: goal.name,
                        goalDescription: goal.description,
                        dates: goal.dates,
                        isActive: goal.isActive,
                        isCompleted: goal.isCompleted,
                        dosage: goal.dosage,
                        units: goal.units,
                        frequency: goal.frequency
                    )
                    context.insert(sdGoal)
                }
                logger.info("✅ Imported \(commonGoals.goals.count) goals")
            }
            
            // Create default settings if none exist
            let settingsCount = try context.fetchCount(FetchDescriptor<KeepTrackSchemaV1.SDAppSettingsV1>())
            if settingsCount == 0 {
                logger.info("Creating default settings")
                let settings = KeepTrackSchemaV1.SDAppSettingsV1()
                // Import license acceptance from UserDefaults if it exists
                if let version = UserDefaults.standard.string(forKey: "AcceptedLicenseVersion") {
                    settings.acceptedLicenseVersion = version
                }
                context.insert(settings)
                logger.info("✅ Created default settings")
            }
            
            // Save all imported data
            try context.save()
            logger.info("🎉 Legacy JSON data import completed successfully!")
            
        } catch {
            logger.error("❌ Error importing legacy JSON data: \(error)")
        }
    }
    
    /// Migration from V1 (with unique constraints) to V2 (CloudKit compatible + new SDAppSettings fields)
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: KeepTrackSchemaV1.self,
        toVersion: KeepTrackSchemaV2.self,
        willMigrate: { context in
            // Log the start of migration
            print("🔄 Starting migration from V1 to V2")
            print("   - Removing unique constraints (CloudKit compatible)")
            print("   - Adding new permission tracking fields to SDAppSettings")
        },
        didMigrate: { context in
            print("✅ Migration from V1 to V2 completed successfully")
            
            // Update existing SDAppSettings with default values for new fields
            do {
                let settingsDescriptor = FetchDescriptor<SDAppSettings>()
                let allSettings = try context.fetch(settingsDescriptor)
                
                for settings in allSettings {
                    // Set default values for new permission fields (if not already set)
                    // These will be false by default from the model, but we log it for clarity
                    settings.modifiedAt = Date()
                }
                
                try context.save()
                
                // Validate data integrity
                let entryCount = try context.fetchCount(FetchDescriptor<SDEntry>())
                let typeCount = try context.fetchCount(FetchDescriptor<SDIntakeType>())
                let goalCount = try context.fetchCount(FetchDescriptor<SDGoal>())
                let settingsCount = try context.fetchCount(FetchDescriptor<SDAppSettings>())
                
                print("📊 Migration results:")
                print("   - Entries: \(entryCount)")
                print("   - Intake Types: \(typeCount)")
                print("   - Goals: \(goalCount)")
                print("   - Settings: \(settingsCount)")
            } catch {
                print("⚠️ Error during migration: \(error)")
            }
        }
    )
}

// MARK: - Schema V0 (Original SwiftData schema - unversioned)
//
// This represents the FIRST SwiftData schema that was on your device
// before versioning was introduced. It matches the current models but
// without version tracking.

enum KeepTrackSchemaV0: VersionedSchema {
    // Version identifier for V0 - represents unversioned initial schema
    static var versionIdentifier = Schema.Version(0, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            SDEntryV0.self,
            SDIntakeTypeV0.self,
            SDGoalV0.self,
            SDAppSettingsV0.self
        ]
    }
    
    @Model
    final class SDEntryV0 {
        var id: UUID
        var date: Date
        var units: String
        var amount: Double
        var name: String
        var goalMet: Bool
        var intakeType: SDIntakeTypeV0?
        
        init(id: UUID = UUID(), date: Date, units: String, amount: Double, name: String, goalMet: Bool) {
            self.id = id
            self.date = date
            self.units = units
            self.amount = amount
            self.name = name
            self.goalMet = goalMet
        }
    }
    
    @Model
    final class SDIntakeTypeV0 {
        var id: UUID
        var name: String
        var unit: String
        var amount: Double
        var descrip: String
        var frequency: String
        
        @Relationship(deleteRule: .nullify, inverse: \SDEntryV0.intakeType)
        var entries: [SDEntryV0]?
        
        init(id: UUID = UUID(), name: String, unit: String, amount: Double, descrip: String, frequency: String) {
            self.id = id
            self.name = name
            self.unit = unit
            self.amount = amount
            self.descrip = descrip
            self.frequency = frequency
        }
    }
    
    @Model
    final class SDGoalV0 {
        var id: UUID
        var name: String
        var goalDescription: String
        var dates: [Date]
        var isActive: Bool
        var isCompleted: Bool
        var dosage: Double
        var units: String
        var frequency: String
        
        init(id: UUID = UUID(), name: String, goalDescription: String, dates: [Date],
             isActive: Bool, isCompleted: Bool, dosage: Double, units: String, frequency: String) {
            self.id = id
            self.name = name
            self.goalDescription = goalDescription
            self.dates = dates
            self.isActive = isActive
            self.isCompleted = isCompleted
            self.dosage = dosage
            self.units = units
            self.frequency = frequency
        }
    }
    
    @Model
    final class SDAppSettingsV0 {
        var id: UUID
        var notificationsEnabled: Bool
        var defaultReminderTime: Date?
        var preferredUnits: String
        var theme: String
        var lastBackupDate: Date?
        var autoBackupEnabled: Bool
        var cloudSyncEnabled: Bool
        var acceptedLicenseVersion: String?
        var createdAt: Date
        var modifiedAt: Date
        
        init(id: UUID = UUID(),
             notificationsEnabled: Bool = true,
             defaultReminderTime: Date? = nil,
             preferredUnits: String = "metric",
             theme: String = "auto",
             lastBackupDate: Date? = nil,
             autoBackupEnabled: Bool = false,
             cloudSyncEnabled: Bool = true,
             acceptedLicenseVersion: String? = nil) {
            self.id = id
            self.notificationsEnabled = notificationsEnabled
            self.defaultReminderTime = defaultReminderTime
            self.preferredUnits = preferredUnits
            self.theme = theme
            self.lastBackupDate = lastBackupDate
            self.autoBackupEnabled = autoBackupEnabled
            self.cloudSyncEnabled = cloudSyncEnabled
            self.acceptedLicenseVersion = acceptedLicenseVersion
            self.createdAt = Date()
            self.modifiedAt = Date()
        }
    }
}

// MARK: - Schema V1 (Original - with unique constraints)

enum KeepTrackSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            SDEntryV1.self,
            SDIntakeTypeV1.self,
            SDGoalV1.self,
            SDAppSettingsV1.self
        ]
    }
    
    @Model
    final class SDEntryV1 {
        @Attribute(.unique) var id: UUID
        var date: Date
        var units: String
        var amount: Double
        var name: String
        var goalMet: Bool
        var intakeType: SDIntakeTypeV1?
        
        init(id: UUID = UUID(), date: Date, units: String, amount: Double, name: String, goalMet: Bool) {
            self.id = id
            self.date = date
            self.units = units
            self.amount = amount
            self.name = name
            self.goalMet = goalMet
        }
    }
    
    @Model
    final class SDIntakeTypeV1 {
        @Attribute(.unique) var id: UUID
        var name: String
        var unit: String
        var amount: Double
        var descrip: String
        var frequency: String
        
        @Relationship(deleteRule: .nullify, inverse: \SDEntryV1.intakeType)
        var entries: [SDEntryV1]?
        
        init(id: UUID = UUID(), name: String, unit: String, amount: Double, descrip: String, frequency: String) {
            self.id = id
            self.name = name
            self.unit = unit
            self.amount = amount
            self.descrip = descrip
            self.frequency = frequency
        }
    }
    
    @Model
    final class SDGoalV1 {
        @Attribute(.unique) var id: UUID
        var name: String
        var goalDescription: String
        var dates: [Date]
        var isActive: Bool
        var isCompleted: Bool
        var dosage: Double
        var units: String
        var frequency: String
        
        init(id: UUID = UUID(), name: String, goalDescription: String, dates: [Date],
             isActive: Bool, isCompleted: Bool, dosage: Double, units: String, frequency: String) {
            self.id = id
            self.name = name
            self.goalDescription = goalDescription
            self.dates = dates
            self.isActive = isActive
            self.isCompleted = isCompleted
            self.dosage = dosage
            self.units = units
            self.frequency = frequency
        }
    }
    
    @Model
    final class SDAppSettingsV1 {
        @Attribute(.unique) var id: UUID
        var notificationsEnabled: Bool
        var defaultReminderTime: Date?
        var preferredUnits: String
        var theme: String
        var lastBackupDate: Date?
        var autoBackupEnabled: Bool
        var cloudSyncEnabled: Bool
        var acceptedLicenseVersion: String?
        var createdAt: Date
        var modifiedAt: Date
        
        init(id: UUID = UUID(),
             notificationsEnabled: Bool = true,
             defaultReminderTime: Date? = nil,
             preferredUnits: String = "metric",
             theme: String = "auto",
             lastBackupDate: Date? = nil,
             autoBackupEnabled: Bool = false,
             cloudSyncEnabled: Bool = true,
             acceptedLicenseVersion: String? = nil) {
            self.id = id
            self.notificationsEnabled = notificationsEnabled
            self.defaultReminderTime = defaultReminderTime
            self.preferredUnits = preferredUnits
            self.theme = theme
            self.lastBackupDate = lastBackupDate
            self.autoBackupEnabled = autoBackupEnabled
            self.cloudSyncEnabled = cloudSyncEnabled
            self.acceptedLicenseVersion = acceptedLicenseVersion
            self.createdAt = Date()
            self.modifiedAt = Date()
        }
    }
}

// MARK: - Schema V2 (Current - CloudKit compatible, no unique constraints)

enum KeepTrackSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            SDEntry.self,
            SDIntakeType.self,
            SDGoal.self,
            SDAppSettings.self
        ]
    }
}
