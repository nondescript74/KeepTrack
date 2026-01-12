//
//  SystemPermissionsChecker.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import Foundation
import CloudKit
import OSLog

/// Manages checking system permissions and capabilities required for the app
@MainActor
final class SystemPermissionsChecker: ObservableObject {
    static let shared = SystemPermissionsChecker()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Permissions")
    
    @Published var iCloudAvailable = false
    @Published var iCloudDriveEnabled = false
    @Published var documentsAccessible = false
    @Published var cloudKitAvailable = false
    @Published var lastCheckDate: Date?
    
    @Published var hasWarnings: Bool = false
    @Published var warningMessages: [PermissionWarning] = []
    
    private init() {}
    
    /// Perform all permission checks
    func checkAllPermissions() async {
        logger.info("Starting permission checks...")
        
        await checkiCloudStatus()
        await checkCloudKitStatus()
        checkDocumentsAccess()
        
        updateWarnings()
        lastCheckDate = Date()
        
        // Save results to settings
        await savePermissionStatus()
        
        logger.info("Permission checks completed. iCloud: \(self.iCloudAvailable), CloudKit: \(self.cloudKitAvailable), Docs: \(self.documentsAccessible)")
    }
    
    /// Check if iCloud is available and enabled
    private func checkiCloudStatus() async {
        // Check if iCloud container is accessible
        if FileManager.default.ubiquityIdentityToken != nil {
            iCloudAvailable = true
            logger.info("✅ iCloud is available (token exists)")
        } else {
            iCloudAvailable = false
            logger.warning("❌ iCloud is not available - user may not be signed in to iCloud")
        }
        
        // Check if we can access iCloud Drive
        if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
            iCloudDriveEnabled = true
            logger.info("✅ iCloud Drive is enabled (URL: \(iCloudURL.path))")
        } else {
            iCloudDriveEnabled = false
            logger.warning("❌ iCloud Drive is not enabled or accessible")
        }
    }
    
    /// Check CloudKit availability
    private func checkCloudKitStatus() async {
        let container = CKContainer(identifier: "iCloud.com.headydiscy.KeepTrack")
        
        do {
            let status = try await container.accountStatus()
            
            switch status {
            case .available:
                cloudKitAvailable = true
                logger.info("✅ CloudKit account is available")
                
            case .noAccount:
                cloudKitAvailable = false
                logger.warning("❌ No iCloud account configured on this device")
                
            case .restricted:
                cloudKitAvailable = false
                logger.warning("❌ iCloud account is restricted (parental controls or MDM)")
                
            case .couldNotDetermine:
                cloudKitAvailable = false
                logger.warning("⚠️ Could not determine CloudKit account status")
                
            case .temporarilyUnavailable:
                cloudKitAvailable = false
                logger.warning("⚠️ CloudKit is temporarily unavailable (network issue?)")
                
            @unknown default:
                cloudKitAvailable = false
                logger.warning("⚠️ Unknown CloudKit account status")
            }
        } catch {
            cloudKitAvailable = false
            logger.error("❌ Failed to check CloudKit status: \(error.localizedDescription)")
        }
    }
    
    /// Check if we can access documents directory
    private func checkDocumentsAccess() {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            documentsAccessible = false
            logger.error("❌ Cannot access documents directory - this should never happen!")
            return
        }
        
        logger.info("📁 Documents directory: \(documentsURL.path)")
        
        // Try to create a test directory
        let testDir = documentsURL.appendingPathComponent("PermissionTest")
        
        do {
            try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true, attributes: nil)
            logger.info("✅ Created test directory")
            
            // Try to write a test file
            let testFile = testDir.appendingPathComponent("test.txt")
            let testContent = "KeepTrack permission test - \(Date())"
            try testContent.write(to: testFile, atomically: true, encoding: .utf8)
            logger.info("✅ Wrote test file")
            
            // Try to read it back
            let readContent = try String(contentsOf: testFile, encoding: .utf8)
            guard readContent == testContent else {
                throw NSError(domain: "PermissionTest", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "Read content doesn't match written content"
                ])
            }
            logger.info("✅ Read test file successfully")
            
            // Clean up
            try FileManager.default.removeItem(at: testDir)
            logger.info("✅ Cleaned up test files")
            
            documentsAccessible = true
            logger.info("✅ Documents directory is fully accessible and writable")
        } catch {
            documentsAccessible = false
            logger.error("❌ Documents directory access test failed: \(error.localizedDescription)")
            
            // Try to clean up anyway
            try? FileManager.default.removeItem(at: testDir)
        }
    }
    
    /// Update warning messages based on permission status
    private func updateWarnings() {
        var warnings: [PermissionWarning] = []
        
        if !iCloudAvailable {
            warnings.append(PermissionWarning(
                id: "icloud-unavailable",
                severity: .critical,
                title: "iCloud Not Available",
                message: "Please sign in to iCloud in Settings to enable data sync and backups.",
                action: .openSettings
            ))
        }
        
        if !cloudKitAvailable {
            warnings.append(PermissionWarning(
                id: "cloudkit-unavailable",
                severity: .warning,
                title: "CloudKit Unavailable",
                message: "Your data will not sync across devices. Check your iCloud settings.",
                action: .openSettings
            ))
        }
        
        if !documentsAccessible {
            warnings.append(PermissionWarning(
                id: "documents-inaccessible",
                severity: .critical,
                title: "Cannot Access Storage",
                message: "The app cannot save backups. Please check storage permissions and available space.",
                action: .none
            ))
        }
        
        if !iCloudDriveEnabled && iCloudAvailable {
            warnings.append(PermissionWarning(
                id: "icloud-drive-disabled",
                severity: .warning,
                title: "iCloud Drive Disabled",
                message: "Enable iCloud Drive in Settings to enable cloud backups.",
                action: .openSettings
            ))
        }
        
        warningMessages = warnings
        hasWarnings = !warnings.isEmpty
    }
    
    /// Save permission status to app settings
    private func savePermissionStatus() async {
        let manager = SwiftDataManager.shared
        let descriptor = FetchDescriptor<SDAppSettings>()
        
        do {
            let settings = try manager.mainContext.fetch(descriptor).first ?? SDAppSettings()
            if try manager.mainContext.fetch(descriptor).isEmpty {
                manager.mainContext.insert(settings)
            }
            
            settings.iCloudAvailable = iCloudAvailable
            settings.cloudKitAvailable = cloudKitAvailable
            settings.documentsAccessible = documentsAccessible
            settings.lastPermissionCheck = Date()
            
            try manager.mainContext.save()
        } catch {
            logger.error("Failed to save permission status: \(error.localizedDescription)")
        }
    }
}

/// Represents a permission warning
struct PermissionWarning: Identifiable {
    let id: String
    let severity: Severity
    let title: String
    let message: String
    let action: Action
    
    enum Severity {
        case critical  // Red - app functionality severely impacted
        case warning   // Yellow - some features may not work
        case info      // Blue - informational
    }
    
    enum Action {
        case openSettings
        case none
    }
    
    var icon: String {
        switch severity {
        case .critical: return "exclamationmark.triangle.fill"
        case .warning: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var color: String {
        switch severity {
        case .critical: return "red"
        case .warning: return "orange"
        case .info: return "blue"
        }
    }
}

// Extension to import FetchDescriptor
import SwiftData
