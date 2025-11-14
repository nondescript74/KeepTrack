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
    
    private let currentVersion: String
    private let userDefaults: UserDefaults
    private let acceptedVersionKey = "AcceptedLicenseVersion"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        checkLicenseStatus()
    }
    
    private func checkLicenseStatus() {
        let acceptedVersion = userDefaults.string(forKey: acceptedVersionKey)
        hasAcceptedCurrentVersion = acceptedVersion == currentVersion
        isCheckingLicense = false
    }
    
    func acceptLicense() {
        userDefaults.set(currentVersion, forKey: acceptedVersionKey)
        hasAcceptedCurrentVersion = true
    }
    
    func resetLicenseAcceptance() {
        userDefaults.removeObject(forKey: acceptedVersionKey)
        hasAcceptedCurrentVersion = false
    }
    
    var currentAppVersion: String {
        currentVersion
    }
}
