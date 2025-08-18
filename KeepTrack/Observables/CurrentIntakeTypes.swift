//
//  CurrentIntakeTypes.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/2/25.
//

import Foundation
import SwiftUI
import OSLog

@MainActor
@Observable final class CurrentIntakeTypes {
    // MARK: - Properties
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CurrentIntakeTypes")
    private static let intakeTypesFilename = "intakeTypes.json"
    private let fileURL: URL
    
    var intakeTypeArray: [IntakeType] = []
    var intakeTypeNameArray: [String] {
        intakeTypeArray.map(\.name)
    }
    
    // MARK: - Init
    init() {
        // Get documents directory for read/write
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let docDirUrl = urls.first {
            self.fileURL = docDirUrl.appendingPathComponent(Self.intakeTypesFilename)
        } else {
            self.fileURL = URL(fileURLWithPath: "/dev/null")
            logger.fault("Failed to resolve document directory")
        }
        // Load asynchronously after init
        Task { await self.loadIntakeTypes() }
    }
    
    // MARK: - Persistence (concurrent)
    func loadIntakeTypes() async {
//        let fileURL = self.fileURL
//        let logger = self.logger
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                if FileManager.default.fileExists(atPath: self.fileURL.path) {
                    do {
                        let data = try Data(contentsOf: self.fileURL)
                        let types = try JSONDecoder().decode([IntakeType].self, from: data)
                        Task { @MainActor in
                            self.intakeTypeArray = types
                            self.logger.info("Loaded \(types.count) intake types")
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
                            Task { @MainActor in
                                self.intakeTypeArray = types
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

