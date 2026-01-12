//
//  AutoBackupScheduler.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import SwiftData
import OSLog

/// Manages automatic backup scheduling
@MainActor
final class AutoBackupScheduler: ObservableObject {
    static let shared = AutoBackupScheduler()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "AutoBackup")
    
    @Published var isScheduled = false
    @Published var nextScheduledBackup: Date?
    
    private var backupTimer: Timer?
    private let backupInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    
    private init() {
        // Start monitoring for auto-backup settings
        Task {
            await checkAndScheduleIfNeeded()
        }
    }
    
    /// Check if auto-backup is enabled and schedule if needed
    func checkAndScheduleIfNeeded() async {
        if await isAutoBackupEnabled() {
            await scheduleAutoBackup()
        } else {
            cancelScheduledBackup()
        }
    }
    
    /// Schedule next automatic backup
    func scheduleAutoBackup() async {
        guard await isAutoBackupEnabled() else {
            logger.info("Auto backup disabled, not scheduling")
            cancelScheduledBackup()
            return
        }
        
        // Cancel existing timer if any
        backupTimer?.invalidate()
        
        // Calculate next backup time (24 hours from now)
        let nextBackupDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date()
        nextScheduledBackup = nextBackupDate
        
        // Schedule timer
        let timeInterval = nextBackupDate.timeIntervalSinceNow
        backupTimer = Timer.scheduledTimer(withTimeInterval: max(timeInterval, 60), repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.handleAutoBackup()
            }
        }
        
        isScheduled = true
        logger.info("Auto backup scheduled for \(nextBackupDate.description)")
    }
    
    /// Cancel scheduled backup
    func cancelScheduledBackup() {
        backupTimer?.invalidate()
        backupTimer = nil
        isScheduled = false
        nextScheduledBackup = nil
        logger.info("Auto backup cancelled")
    }
    
    /// Handle automatic backup
    private func handleAutoBackup() async {
        logger.info("Auto backup task started")
        
        do {
            try await performBackup()
            logger.info("Auto backup completed successfully")
        } catch {
            logger.error("Auto backup failed: \(error.localizedDescription)")
        }
        
        // Schedule next occurrence
        await scheduleAutoBackup()
    }
    
    /// Perform the actual backup
    private func performBackup() async throws {
        // Check permissions first
        let permissionsChecker = SystemPermissionsChecker.shared
        guard permissionsChecker.documentsAccessible else {
            logger.error("Cannot perform backup - documents directory not accessible")
            throw BackupError_MABS.documentsNotAccessible
        }
        
        let manager = SwiftDataManager.shared
        let migrationManager = DataMigrationManager(modelContext: manager.mainContext)
        
        // Create backup URL in documents directory
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw BackupError_MABS.noDocumentsDirectory
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        let filename = "AutoBackup-\(formatter.string(from: Date())).json"
        let backupURL = documentsURL.appendingPathComponent("Backups").appendingPathComponent(filename)
        
        // Create backups directory if needed
        let backupsDir = documentsURL.appendingPathComponent("Backups")
        try FileManager.default.createDirectory(at: backupsDir, withIntermediateDirectories: true, attributes: nil)
        
        // Export backup
        try await migrationManager.exportBackup(to: backupURL)
        
        // Update last backup date
        let descriptor = FetchDescriptor<SDAppSettings>()
        if let settings = try manager.mainContext.fetch(descriptor).first {
            settings.lastBackupDate = Date()
            try manager.mainContext.save()
        }
        
        // Clean up old backups (keep last 5)
        try await cleanupOldBackups(in: backupsDir)
        
        logger.info("Auto backup saved to \(backupURL.path)")
    }
    
    /// Remove old backup files, keeping only the most recent
    private func cleanupOldBackups(in directory: URL) async throws {
        let fileManager = FileManager.default
        let backupFiles = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )
        .filter { $0.pathExtension == "json" }
        .sorted { file1, file2 in
            let date1 = try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate
            let date2 = try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate
            return (date1 ?? Date.distantPast) > (date2 ?? Date.distantPast)
        }
        
        // Keep only the 5 most recent backups
        let filesToDelete = backupFiles.dropFirst(5)
        for file in filesToDelete {
            try fileManager.removeItem(at: file)
            logger.info("Deleted old backup: \(file.lastPathComponent)")
        }
    }
    
    /// Check if auto backup is enabled
    private func isAutoBackupEnabled() async -> Bool {
        let manager = SwiftDataManager.shared
        let descriptor = FetchDescriptor<SDAppSettings>()
        
        do {
            let settings = try manager.mainContext.fetch(descriptor).first
            return settings?.autoBackupEnabled ?? false
        } catch {
            logger.error("Failed to check auto backup setting: \(error.localizedDescription)")
            return false
        }
    }
}

enum BackupError_MABS: Error, LocalizedError {
    case noDocumentsDirectory
    case documentsNotAccessible
    
    var errorDescription: String? {
        switch self {
        case .noDocumentsDirectory:
            return "Unable to access documents directory for backup"
        case .documentsNotAccessible:
            return "Storage access is not available. Please check app permissions and available space."
        }
    }
}
