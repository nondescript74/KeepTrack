//
//  LicenseManager.swift
//  KeepTrack
//
//  Created on 11/13/25.
//

import Foundation
import Observation

@Observable
class LicenseManager {
    private(set) var hasAcceptedCurrentVersion: Bool = false
    private(set) var isCheckingLicense: Bool = true
    private(set) var acceptedVersion: String?
    private(set) var acceptedDate: Date?
    
    private let currentVersion: String
    private let userDefaults: UserDefaults
    private let acceptedVersionKey = "AcceptedLicenseVersion"
    private let acceptedDateKey = "AcceptedLicenseDate"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        checkLicenseStatus()
    }
    
    private func checkLicenseStatus() {
        let storedVersion = userDefaults.string(forKey: acceptedVersionKey)
        let storedDate = userDefaults.object(forKey: acceptedDateKey) as? Date
        
        acceptedVersion = storedVersion
        acceptedDate = storedDate
        hasAcceptedCurrentVersion = storedVersion == currentVersion
        isCheckingLicense = false
    }
    
    func acceptLicense() {
        let now = Date()
        userDefaults.set(currentVersion, forKey: acceptedVersionKey)
        userDefaults.set(now, forKey: acceptedDateKey)
        
        acceptedVersion = currentVersion
        acceptedDate = now
        hasAcceptedCurrentVersion = true
    }
    
    func resetLicenseAcceptance() {
        userDefaults.removeObject(forKey: acceptedVersionKey)
        userDefaults.removeObject(forKey: acceptedDateKey)
        
        acceptedVersion = nil
        acceptedDate = nil
        hasAcceptedCurrentVersion = false
    }
    
    var currentAppVersion: String {
        currentVersion
    }
    
    /// Returns a formatted string showing when and for which version the license was accepted
    var acceptanceInfo: String? {
        guard let version = acceptedVersion, let date = acceptedDate else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return "Version \(version) accepted on \(formatter.string(from: date))"
    }
}
