//
//  SDAppSettings.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import SwiftData

/// SwiftData model for app settings
/// Syncs via CloudKit when configured
@Model
final class SDAppSettings {
    // CloudKit doesn't support unique constraints, so we remove @Attribute(.unique)
    var id: UUID = UUID()
    
    // Notification settings
    var notificationsEnabled: Bool = true
    var defaultReminderTime: Date?
    
    // Display preferences
    var preferredUnits: String = "metric"  // "metric" or "imperial"
    var theme: String = "auto"  // "light", "dark", "auto"
    
    // Data preferences
    var lastBackupDate: Date?
    var autoBackupEnabled: Bool = false
    var cloudSyncEnabled: Bool = true
    
    // Permission tracking
    var iCloudAvailable: Bool = false
    var cloudKitAvailable: Bool = false
    var documentsAccessible: Bool = false
    var lastPermissionCheck: Date?
    
    // License
    var acceptedLicenseVersion: String?
    
    // Other settings as needed
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()
    
    init(id: UUID = UUID(), 
         notificationsEnabled: Bool = true,
         defaultReminderTime: Date? = nil,
         preferredUnits: String = "metric",
         theme: String = "auto",
         lastBackupDate: Date? = nil,
         autoBackupEnabled: Bool = false,
         cloudSyncEnabled: Bool = true,
         iCloudAvailable: Bool = false,
         cloudKitAvailable: Bool = false,
         documentsAccessible: Bool = false,
         lastPermissionCheck: Date? = nil,
         acceptedLicenseVersion: String? = nil) {
        self.id = id
        self.notificationsEnabled = notificationsEnabled
        self.defaultReminderTime = defaultReminderTime
        self.preferredUnits = preferredUnits
        self.theme = theme
        self.lastBackupDate = lastBackupDate
        self.autoBackupEnabled = autoBackupEnabled
        self.cloudSyncEnabled = cloudSyncEnabled
        self.iCloudAvailable = iCloudAvailable
        self.cloudKitAvailable = cloudKitAvailable
        self.documentsAccessible = documentsAccessible
        self.lastPermissionCheck = lastPermissionCheck
        self.acceptedLicenseVersion = acceptedLicenseVersion
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}
