//
//  LicenseManagerTests.swift
//  KeepTrack
//
//  Created on 11/13/25.
//

import Testing
import Foundation
@testable import KeepTrack

@Suite("License Manager Tests")
struct LicenseManagerTests {
    
    @Test("Initial state should not have accepted license")
    func initialStateNotAccepted() async throws {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.removePersistentDomain(forName: #function)
        
        let manager = LicenseManager(userDefaults: userDefaults)
        
        #expect(manager.hasAcceptedCurrentVersion == false)
        #expect(manager.isCheckingLicense == false)
    }
    
    @Test("Accepting license should update state")
    func acceptingLicense() async throws {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.removePersistentDomain(forName: #function)
        
        let manager = LicenseManager(userDefaults: userDefaults)
        
        #expect(manager.hasAcceptedCurrentVersion == false)
        
        manager.acceptLicense()
        
        #expect(manager.hasAcceptedCurrentVersion == true)
    }
    
    @Test("License acceptance should persist across instances")
    func licenseAcceptancePersists() async throws {
        let suiteName = #function
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        
        let firstManager = LicenseManager(userDefaults: userDefaults)
        firstManager.acceptLicense()
        
        let secondManager = LicenseManager(userDefaults: userDefaults)
        
        #expect(secondManager.hasAcceptedCurrentVersion == true)
    }
    
    @Test("Resetting license should clear acceptance")
    func resetLicense() async throws {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.removePersistentDomain(forName: #function)
        
        let manager = LicenseManager(userDefaults: userDefaults)
        manager.acceptLicense()
        
        #expect(manager.hasAcceptedCurrentVersion == true)
        
        manager.resetLicenseAcceptance()
        
        #expect(manager.hasAcceptedCurrentVersion == false)
    }
    
    @Test("Current app version should be available")
    func currentVersionAvailable() async throws {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.removePersistentDomain(forName: #function)
        
        let manager = LicenseManager(userDefaults: userDefaults)
        
        #expect(!manager.currentAppVersion.isEmpty)
    }
    
    @Test("Different version should require new acceptance")
    func differentVersionRequiresAcceptance() async throws {
        let suiteName = #function
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        
        // Simulate accepting an old version
        userDefaults.set("1.0", forKey: "AcceptedLicenseVersion")
        
        let manager = LicenseManager(userDefaults: userDefaults)
        
        // If current version is not "1.0", this should be false
        if manager.currentAppVersion != "1.0" {
            #expect(manager.hasAcceptedCurrentVersion == false)
        }
    }
}
