//
//  SwiftDataSchemaMigration.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import Foundation
import SwiftData

/// Schema migration plan for SwiftData model changes
enum KeepTrackSchemaMigrationPlan: SchemaMigrationPlan {
    
    // Define all schema versions
    static var schemas: [any VersionedSchema.Type] {
        [
            KeepTrackSchemaV1.self,  // Original schema with @Attribute(.unique)
            KeepTrackSchemaV2.self   // Current schema without unique constraints (CloudKit compatible)
        ]
    }
    
    // Define migration stages
    static var stages: [MigrationStage] {
        [
            // Migration from V1 to V2
            migrateV1toV2
        ]
    }
    
    /// Migration from V1 (with unique constraints) to V2 (CloudKit compatible)
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: KeepTrackSchemaV1.self,
        toVersion: KeepTrackSchemaV2.self,
        willMigrate: { context in
            // Log the start of migration
            print("🔄 Starting migration from V1 to V2 (removing unique constraints)")
        },
        didMigrate: { context in
            // Migration is handled automatically by SwiftData
            // The unique constraint removal is a lightweight migration
            print("✅ Migration from V1 to V2 completed successfully")
            
            // Optional: Validate data integrity
            do {
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
                print("⚠️ Error validating migration: \(error)")
            }
        }
    )
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
