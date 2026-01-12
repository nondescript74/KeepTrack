//
//  SwiftDataManager.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import SwiftData
import OSLog

/// Manages SwiftData container with CloudKit sync
@MainActor
final class SwiftDataManager {
    static let shared = SwiftDataManager()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "SwiftDataManager")
    
    /// The main model container with CloudKit sync enabled
    var container: ModelContainer!
    
    /// Indicates whether CloudKit sync is active
    private(set) var isCloudKitEnabled = false
    
    /// Main context for UI operations
    var mainContext: ModelContext {
        container.mainContext
    }
    
    private init() {
        // Try CloudKit configuration first
        do {
            logger.info("🔄 Attempting to initialize with CloudKit sync and migration...")
            
            // Primary configuration: CloudKit sync with App Group
            let cloudKitConfiguration = ModelConfiguration(
                isStoredInMemoryOnly: false,
                allowsSave: true,
                groupContainer: .identifier("group.com.headydiscy.KeepTrack"),
                cloudKitDatabase: .private("iCloud.com.headydiscy.KeepTrack")
            )
            
            container = try ModelContainer(
                for: SDEntry.self, SDIntakeType.self, SDGoal.self, SDAppSettings.self,
                migrationPlan: KeepTrackSchemaMigrationPlan.self,
                configurations: cloudKitConfiguration
            )
            container.mainContext.autosaveEnabled = true
            isCloudKitEnabled = true
            logger.info("✅ SwiftData container initialized with CloudKit sync")
        } catch {
            logger.error("❌ CloudKit initialization failed: \(error.localizedDescription)")
            
            // Check if this is the "unknown model version" error
            let errorString = String(describing: error)
            let isUnknownVersionError = errorString.contains("134504") || 
                                       errorString.contains("unknown model version") ||
                                       errorString.contains("loadIssueModelContainer")
            
            if isUnknownVersionError {
                logger.warning("⚠️ Detected unversioned SwiftData database. Attempting to reset and re-import...")
                
                // Delete the existing unversioned database from App Group
                let fileManager = FileManager.default
                if let appGroupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.headydiscy.KeepTrack") {
                    let storeURL = appGroupURL.appendingPathComponent("Library/Application Support/default.store")
                    
                    // Remove the old database files
                    try? fileManager.removeItem(at: storeURL)
                    try? fileManager.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-shm"))
                    try? fileManager.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-wal"))
                    
                    logger.info("🗑️ Removed old unversioned database from App Group. Will re-import from JSON...")
                }
                
                // Now try again with CloudKit
                do {
                    let cloudKitConfiguration = ModelConfiguration(
                        isStoredInMemoryOnly: false,
                        allowsSave: true,
                        groupContainer: .identifier("group.com.headydiscy.KeepTrack"),
                        cloudKitDatabase: .private("iCloud.com.headydiscy.KeepTrack")
                    )
                    
                    container = try ModelContainer(
                        for: SDEntry.self, SDIntakeType.self, SDGoal.self, SDAppSettings.self,
                        migrationPlan: KeepTrackSchemaMigrationPlan.self,
                        configurations: cloudKitConfiguration
                    )
                    container.mainContext.autosaveEnabled = true
                    isCloudKitEnabled = true
                    logger.info("✅ SwiftData container re-initialized with CloudKit sync after database reset")
                } catch {
                    logger.error("❌ CloudKit initialization failed after reset: \(error.localizedDescription)")
                    // Fall through to local storage fallback
                    do {
                        try initializeLocalStorage()
                    } catch {
                        fatalError("Failed to initialize ModelContainer: \(error)")
                    }
                }
            } else {
                // Different error, try local storage
                logger.warning("⚠️ Falling back to local storage without CloudKit sync...")
                do {
                    try initializeLocalStorage()
                } catch {
                    fatalError("Failed to initialize ModelContainer: \(error)")
                }
            }
        }
        
        // Perform JSON to SwiftData migration if needed (runs after container is ready)
        Task {
            do {
                let migrationManager = DataMigrationManager(modelContext: mainContext)
                if !migrationManager.isMigrationCompleted {
                    logger.info("🔄 Starting JSON to SwiftData migration...")
                    try await migrationManager.migrateAllData()
                    logger.info("✅ JSON to SwiftData migration completed")
                } else {
                    logger.info("ℹ️ JSON to SwiftData migration already completed")
                }
            } catch {
                logger.error("❌ JSON to SwiftData migration failed: \(error)")
            }
        }
    }
    
    /// Helper to initialize with local storage (no CloudKit)
    private func initializeLocalStorage() throws {
        do {
            // Fallback configuration: Local storage without CloudKit
            let localConfiguration = ModelConfiguration(
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            container = try ModelContainer(
                for: SDEntry.self, SDIntakeType.self, SDGoal.self, SDAppSettings.self,
                migrationPlan: KeepTrackSchemaMigrationPlan.self,
                configurations: localConfiguration
            )
            container.mainContext.autosaveEnabled = true
            logger.warning("⚠️ SwiftData container initialized with LOCAL storage only")
            logger.warning("⚠️ Data will NOT sync via iCloud")
        } catch {
            // Check if this is the "unknown model version" error
            let errorString = String(describing: error)
            let isUnknownVersionError = errorString.contains("134504") || 
                                       errorString.contains("unknown model version") ||
                                       errorString.contains("loadIssueModelContainer")
            
            if isUnknownVersionError {
                logger.warning("⚠️ Local database also unversioned. Resetting...")
                
                let fileManager = FileManager.default
                if let documentsURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                    let storeURL = documentsURL.appendingPathComponent("default.store")
                    
                    try? fileManager.removeItem(at: storeURL)
                    try? fileManager.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-shm"))
                    try? fileManager.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-wal"))
                    
                    logger.info("🗑️ Removed old local database. Will re-import from JSON...")
                }
                
                // Try one more time
                let localConfiguration = ModelConfiguration(
                    isStoredInMemoryOnly: false,
                    allowsSave: true
                )
                
                container = try ModelContainer(
                    for: SDEntry.self, SDIntakeType.self, SDGoal.self, SDAppSettings.self,
                    migrationPlan: KeepTrackSchemaMigrationPlan.self,
                    configurations: localConfiguration
                )
                container.mainContext.autosaveEnabled = true
                logger.info("✅ SwiftData container initialized with local storage after reset")
            } else {
                logger.fault("❌ FATAL: Failed to initialize even with local storage: \(error)")
                logger.fault("   Error details: \(String(describing: error))")
                throw error
            }
        }
    }
    
    /// Create a background context for async operations
    func newBackgroundContext() -> ModelContext {
        let context = ModelContext(container)
        return context
    }
}
