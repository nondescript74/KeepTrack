//
//  CurrentIntakeTypes.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/2/25.
//

import Foundation
import OSLog

@MainActor
final class CurrentIntakeTypes: ObservableObject {
    // MARK: - Properties
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CurrentIntakeTypes")
    private static let intakeTypesFilename = "intakeTypes.json"
    private let fileURL: URL
    
    @Published
    var intakeTypeArray: [IntakeType] = []
    var intakeTypeNameArray: [String] {
        intakeTypeArray.map(\.name)
    }
    
    var sortedIntakeTypeArray: [IntakeType] {
        intakeTypeArray.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var sortedIntakeTypeNameArray: [String] {
        sortedIntakeTypeArray.map(\.name)
    }
    
    // MARK: - Init
    init() {
        // Use App Group container for shared storage between app and intents
        let appGroupID = "group.com.headydiscy.KeepTrack" // Replace with your real App Group identifier
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            self.fileURL = containerURL.appendingPathComponent(Self.intakeTypesFilename)
        } else {
            self.fileURL = URL(fileURLWithPath: "/dev/null")
            logger.fault("Failed to resolve App Group container directory")
        }
        // Ensure intakeTypes.json exists in the App Group container
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: self.fileURL.path) {
            if let bundleURL = Bundle.main.url(forResource: "intakeTypes", withExtension: "json") {
                do {
                    try fileManager.copyItem(at: bundleURL, to: self.fileURL)
                    logger.info("Copied default intakeTypes.json to App Group container")
                } catch {
                    logger.error("Failed to copy intakeTypes.json: \(error.localizedDescription)")
                }
            } else {
                logger.error("Default intakeTypes.json not found in bundle")
            }
        }
        
        // Load asynchronously after init
        Task { await self.loadIntakeTypes() }
        
        logger.info("CurrentIntakeTypes initialized with fileURL: \(self.fileURL.absoluteString, privacy: .public)")
    }
    

    
    // MARK: - Persistence (concurrent)
    func loadIntakeTypes() async {
        logger.info("intakeTypes.json exists: \(FileManager.default.fileExists(atPath: self.fileURL.path), privacy: .public) at path: \(self.fileURL.path, privacy: .public)")
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                if FileManager.default.fileExists(atPath: self.fileURL.path) {
                    do {
                        let data = try Data(contentsOf: self.fileURL)
                        let types = try JSONDecoder().decode([IntakeType].self, from: data)
                        let sortedTypes = types.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                        Task { @MainActor in
                            self.intakeTypeArray = sortedTypes
                            self.logger.info("Loaded \(sortedTypes.count) intake types")
                            continuation.resume()
                        }
                    } catch {
                        Task { @MainActor in
                            self.intakeTypeArray = []
                            self.logger.error("Failed to load intake types: \(error.localizedDescription)")
                            continuation.resume()
                        }
                    }
                } else {
                    // Read the file from the bundle
                    if let bundleURL = Bundle.main.url(forResource: "intakeTypes", withExtension: "json") {
                        do {
                            let data = try Data(contentsOf: bundleURL)
                            let types = try JSONDecoder().decode([IntakeType].self, from: data)
                            let sortedTypes = types.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                            Task { @MainActor in
                                self.intakeTypeArray = sortedTypes
                                self.logger.info("Loaded intake types from bundle")
                                continuation.resume()
                            }
                        } catch {
                            Task { @MainActor in
                                self.intakeTypeArray = []
                                self.logger.error("Failed to load intake types from bundle: \(error.localizedDescription)")
                                continuation.resume()
                            }
                        }
                    } else {
                        Task { @MainActor in
                            self.intakeTypeArray = []
                            self.logger.error("Bundle intake types file not found")
                            continuation.resume()
                        }
                    }
                    
                }
            }
        }
    }
    
    func saveNewIntakeType(intakeType: IntakeType) {
        self.intakeTypeArray.append(intakeType)
        self.intakeTypeArray.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        Task {
            await self.saveIntakeTypes()
        }
    }
    
    /// Save the array to file off the main actor
    func saveIntakeTypes() async {
        let types = self.intakeTypeArray
//        let fileURL = self.fileURL
//        let logger = self.logger
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                do {
                    let data = try JSONEncoder().encode(types)
                    try data.write(to: self.fileURL, options: [.atomic])
                    self.logger.info("CurrentIntakeTypes: Saved intakeTypeArray to disk")
                } catch {
                    self.logger.error("CurrentIntakeTypes: cannot write to file: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
    }
    
    /// Force reload from bundle - useful during development to pick up JSON changes
    func reloadFromBundle() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let fileManager = FileManager.default
                
                // Check if bundle has a newer version
                guard let bundleURL = Bundle.main.url(forResource: "intakeTypes", withExtension: "json") else {
                    self.logger.error("Bundle intakeTypes.json not found")
                    continuation.resume()
                    return
                }
                
                // Delete existing file in App Group if it exists
                if fileManager.fileExists(atPath: self.fileURL.path) {
                    do {
                        try fileManager.removeItem(at: self.fileURL)
                        self.logger.info("Deleted existing intakeTypes.json from App Group")
                    } catch {
                        self.logger.error("Failed to delete existing file: \(error.localizedDescription)")
                    }
                }
                
                // Copy fresh from bundle
                do {
                    try fileManager.copyItem(at: bundleURL, to: self.fileURL)
                    self.logger.info("Copied fresh intakeTypes.json from bundle")
                    
                    // Now load the fresh data
                    let data = try Data(contentsOf: self.fileURL)
                    let types = try JSONDecoder().decode([IntakeType].self, from: data)
                    let sortedTypes = types.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                    
                    Task { @MainActor in
                        self.intakeTypeArray = sortedTypes
                        self.logger.info("Reloaded \(sortedTypes.count) intake types from bundle")
                        continuation.resume()
                    }
                } catch {
                    self.logger.error("Failed to reload from bundle: \(error.localizedDescription)")
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Helpers
    func getunits(typeName: String) -> String {
        switch typeName.lowercased() {
        case "amlodipine":
            return "mg"
        case "losartan":
            return "mg"
        case "timolol":
            return "ml"
        case "rosuvastatin":
            return "mg"
        case "coffee":
            return "fluidOunces"
        default:
            return "mg"
        }
    }
    
    func getamount(typeName: String) -> Double {
        switch typeName.lowercased() {
        case "amlodipine":
            return 5
        case "losartan":
            return 25
        case "timolol":
            return 1
        case "rosuvastatin":
            return 20
        case "potassium chloride":
            return 99
        case "coffee":
            return 3
        default:
            return 0
        }
    }
}
