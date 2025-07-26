//
//  CurrentIntakeTypes.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/2/25.
//

import Foundation
import SwiftUI
import OSLog


@Observable final class CurrentIntakeTypes: ObservableObject {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CurrentIntakeTypes")
    var intakeTypeArray: [IntakeType]
    var intakeTypeNameArray: [String] {
        intakeTypeArray.map(\.self.name)
    }
    
    init() {
        if let fileURL = Bundle.main.url(forResource: "intakeTypes", withExtension: "json") {
            // File found, proceed to read it
            let data: Data = try! Data(contentsOf: fileURL)
            intakeTypeArray = try! JSONDecoder().decode([IntakeType].self, from: data)
            logger.info("Loaded \(self.intakeTypeArray.count) intake types")
        } else {
            intakeTypeArray = []
            logger.info( "No intake types file found")
        }

    }
    
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
        default:
            return 0
        }
    }

}
