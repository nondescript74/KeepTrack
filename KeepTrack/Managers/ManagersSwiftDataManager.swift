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
    let container: ModelContainer
    
    /// Main context for UI operations
    var mainContext: ModelContext {
        container.mainContext
    }
    
    private init() {
        // Configure CloudKit sync with migration plan
        let modelConfiguration = ModelConfiguration(
            schema: Schema([
                SDEntry.self,
                SDIntakeType.self,
                SDGoal.self,
                SDAppSettings.self
            ]),
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .identifier("group.com.headydiscy.KeepTrack"),
            cloudKitDatabase: .private("iCloud.com.headydiscy.KeepTrack")
        )
        
        do {
            // Initialize container with migration plan
            container = try ModelContainer(
                for: Schema(versionedSchema: KeepTrackSchemaV2.self),
                migrationPlan: KeepTrackSchemaMigrationPlan.self,
                configurations: [modelConfiguration]
            )
            
            // Enable automatic save
            container.mainContext.autosaveEnabled = true
            
            logger.info("SwiftData container initialized with CloudKit sync and migration support")
        } catch let error as NSError {
            logger.fault("Failed to initialize ModelContainer: \(error.localizedDescription)")
            logger.fault("Error domain: \(error.domain), code: \(error.code)")
            logger.fault("User info: \(error.userInfo)")
            
            // Provide more helpful error messages
            if error.domain == "NSCocoaErrorDomain" {
                logger.fault("This might be a CloudKit or App Group configuration issue")
            }
            
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    /// Create a background context for async operations
    func newBackgroundContext() -> ModelContext {
        let context = ModelContext(container)
        return context
    }
}
