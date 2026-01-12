//
//  AutoBackupScheduler.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import SwiftData
import OSLog
import BackgroundTasks

/// Manages automatic backup scheduling
@MainActor
final class AutoBackupScheduler: ObservableObject {
    static let shared = AutoBackupScheduler()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "AutoBackup")
    private let backgroundTaskIdentifier = "com.headydiscy.KeepTrack.autobackup"
    
    @Published var isScheduled = false
    @Published var nextScheduledBackup: Date?
    
    private init() {
        registerBackgroundTask()
    }
    
    /// Register the background task for auto-backup
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { task in
            self.handleAutoBackup(task: task as! BGAppRefreshTask)
        }
        logger.info("Background task registered: \(self.backgroundTaskIdentifier)")
    }
    
    /// Schedule next automatic backup
    func scheduleAutoBackup() async {
        guard await isAutoBackupEnabled() else {
            logger.info("Auto backup disabled, not scheduling")
            cancelScheduledBackup()
            return
        }
        
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        
        // Schedule for 24 hours from now
        request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date())
        
        do {
            try BGTaskScheduler.shared.submit(request)
            nextScheduledBackup = request.earliestBeginDate
            isScheduled = true
            logger.info("Auto backup scheduled for \(request.earliestBeginDate?.description ?? "unknown")")
        } catch {
            logger.error("Failed to schedule auto backup: \(error.localizedDescription)")
            isScheduled = false
        }
    }
    
    /// Cancel scheduled backup
    func cancelScheduledBackup() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)
        isScheduled = false
        nextScheduledBackup = nil
        logger.info("Auto backup cancelled")
    }
    
    /// Handle background backup task
    private func handleAutoBackup(task: BGAppRefreshTask) {
        logger.info("Background auto backup task started")
        
        // Schedule next occurrence
        Task {
            await scheduleAutoBackup()
        }
        
        // Perform backup
        Task {
            do {
                try await performBackup()
                task.setTaskCompleted(success: true)
                logger.info("Auto backup completed successfully")
            } catch {
                logger.error("Auto backup failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    /// Perform the actual backup
    private func performBackup() async throws {
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
        try FileManager.default.createDirectory(at: backupsDir, withIntermediateDirectories: true)
        
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
    
    var errorDescription: String? {
        switch self {
        case .noDocumentsDirectory:
            return "Unable to access documents directory for backup"
        }
    }
}
