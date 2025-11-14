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
    
    @Test("Acceptance date should be stored when license is accepted")
    func acceptanceDateStored() async throws {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.removePersistentDomain(forName: #function)
        
        let manager = LicenseManager(userDefaults: userDefaults)
        
        #expect(manager.acceptedDate == nil)
        
        let beforeAcceptance = Date()
        manager.acceptLicense()
        let afterAcceptance = Date()
        
        #expect(manager.acceptedDate != nil)
        
        if let acceptedDate = manager.acceptedDate {
            #expect(acceptedDate >= beforeAcceptance)
            #expect(acceptedDate <= afterAcceptance)
        }
    }
    
    @Test("Acceptance date should persist across instances")
    func acceptanceDatePersists() async throws {
        let suiteName = #function
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        
        let firstManager = LicenseManager(userDefaults: userDefaults)
        firstManager.acceptLicense()
        
        let acceptedDate = firstManager.acceptedDate
        
        let secondManager = LicenseManager(userDefaults: userDefaults)
        
        #expect(secondManager.acceptedDate == acceptedDate)
    }
    
    @Test("Accepted version should be stored")
    func acceptedVersionStored() async throws {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.removePersistentDomain(forName: #function)
        
        let manager = LicenseManager(userDefaults: userDefaults)
        
        #expect(manager.acceptedVersion == nil)
        
        manager.acceptLicense()
        
        #expect(manager.acceptedVersion == manager.currentAppVersion)
    }
    
    @Test("Acceptance info should be formatted correctly")
    func acceptanceInfoFormatted() async throws {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.removePersistentDomain(forName: #function)
        
        let manager = LicenseManager(userDefaults: userDefaults)
        
        #expect(manager.acceptanceInfo == nil)
        
        manager.acceptLicense()
        
        #expect(manager.acceptanceInfo != nil)
        #expect(manager.acceptanceInfo?.contains(manager.currentAppVersion) == true)
        #expect(manager.acceptanceInfo?.contains("accepted on") == true)
    }
    
    @Test("Resetting should clear both version and date")
    func resetClearsAll() async throws {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.removePersistentDomain(forName: #function)
        
        let manager = LicenseManager(userDefaults: userDefaults)
        manager.acceptLicense()
        
        #expect(manager.acceptedVersion != nil)
        #expect(manager.acceptedDate != nil)
        
        manager.resetLicenseAcceptance()
        
        #expect(manager.acceptedVersion == nil)
        #expect(manager.acceptedDate == nil)
    }
}
