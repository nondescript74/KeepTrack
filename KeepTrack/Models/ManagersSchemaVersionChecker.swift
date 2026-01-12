//
//  SchemaVersionChecker.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import Foundation
import SwiftData
import OSLog

/// Utilities for checking and managing SwiftData schema versions
@MainActor
final class SchemaVersionChecker {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "SchemaVersion")
    
    static let shared = SchemaVersionChecker()
    
    private static let currentSchemaVersionKey = "CurrentSchemaVersion"
    private static let lastMigrationDateKey = "LastMigrationDate"
    
    private init() {}
    
    /// Get the current schema version from UserDefaults
    var currentVersion: String? {
        UserDefaults.standard.string(forKey: Self.currentSchemaVersionKey)
    }
    
    /// Get the last migration date
    var lastMigrationDate: Date? {
        UserDefaults.standard.object(forKey: Self.lastMigrationDateKey) as? Date
    }
    
    /// Record that migration to V2 has completed
    func recordMigrationToV2() {
        UserDefaults.standard.set("2.0.0", forKey: Self.currentSchemaVersionKey)
        UserDefaults.standard.set(Date(), forKey: Self.lastMigrationDateKey)
        logger.info("Recorded migration to schema version 2.0.0")
    }
    
    /// Check if user needs migration from V1 to V2
    func needsMigration() -> Bool {
        guard let version = currentVersion else {
            // First time running with versioning, assume needs migration if data exists
            return hasExistingSwiftDataStore()
        }
        
        // If version is less than 2.0.0, needs migration
        return version.compare("2.0.0", options: .numeric) == .orderedAscending
    }
    
    /// Check if SwiftData store exists (user has used the app before)
    private func hasExistingSwiftDataStore() -> Bool {
        // Check if default.store exists in the app group container
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.headydiscy.KeepTrack"
        ) else {
            return false
        }
        
        let storeURL = containerURL
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("default.store")
        
        let exists = FileManager.default.fileExists(atPath: storeURL.path)
        logger.info("SwiftData store exists: \(exists)")
        return exists
    }
    
    /// Pre-migration backup (for extra safety)
    func createPreMigrationBackup() throws -> URL {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.headydiscy.KeepTrack"
        ) else {
            throw BackupError.containerNotFound
        }
        
        let storeURL = containerURL
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("default.store")
        
        let backupURL = containerURL
            .appendingPathComponent("Backups")
            .appendingPathComponent("pre-migration-\(Date().ISO8601Format()).store")
        
        // Create backups directory if needed
        try FileManager.default.createDirectory(
            at: backupURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        // Copy the store file
        try FileManager.default.copyItem(at: storeURL, to: backupURL)
        
        logger.info("Created pre-migration backup at \(backupURL.path)")
        return backupURL
    }
    
    /// Validate data integrity after migration
    func validateMigration(context: ModelContext) throws -> MigrationValidationReport {
        let entryCount = try context.fetchCount(FetchDescriptor<SDEntry>())
        let typeCount = try context.fetchCount(FetchDescriptor<SDIntakeType>())
        let goalCount = try context.fetchCount(FetchDescriptor<SDGoal>())
        let settingsCount = try context.fetchCount(FetchDescriptor<SDAppSettings>())
        
        // Check for duplicates (shouldn't happen, but good to verify)
        let entries = try context.fetch(FetchDescriptor<SDEntry>())
        let uniqueIDs = Set(entries.map { $0.id })
        let hasDuplicates = uniqueIDs.count != entries.count
        
        let report = MigrationValidationReport(
            entryCount: entryCount,
            typeCount: typeCount,
            goalCount: goalCount,
            settingsCount: settingsCount,
            hasDuplicates: hasDuplicates,
            isValid: !hasDuplicates && settingsCount <= 1
        )
        
        logger.info("Migration validation: \(report)")
        return report
    }
}

// MARK: - Supporting Types

struct MigrationValidationReport: CustomStringConvertible {
    let entryCount: Int
    let typeCount: Int
    let goalCount: Int
    let settingsCount: Int
    let hasDuplicates: Bool
    let isValid: Bool
    
    var description: String {
        """
        Migration Validation Report:
        - Entries: \(entryCount)
        - Intake Types: \(typeCount)
        - Goals: \(goalCount)
        - Settings: \(settingsCount)
        - Has Duplicates: \(hasDuplicates)
        - Valid: \(isValid)
        """
    }
}

enum BackupError: Error, LocalizedError {
    case containerNotFound
    
    var errorDescription: String? {
        switch self {
        case .containerNotFound:
            return "App Group container not found"
        }
    }
}
