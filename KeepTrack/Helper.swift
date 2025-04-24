//
//  Helper.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import Foundation
import SwiftUI
import OSLog

let types = ["Rosuvastatin", "Metformin", "Losartan", "Latanoprost", "Water", "Smoothie", "Protein", "Sake"]

let units: [String] = ["mg", "fluid ounces", "cups", "g", "ozs", "ml", "liters", "pills", "drops", "fluid ounces"]

let matchingUnitsDictionary: Dictionary<String, String> = ["Rosuvastatin": "mg", "Metformin": "mg", "Losartan": "mg", "Latanoprost": "drops", "Water": "fluid ounces", "Smoothie": "fluid ounces", "Protein": "g", "sake": "fluid ounces"]


let matchingAmountDictionary: Dictionary<String, Double> = ["Rosuvastatin": 20.0, "Metformin": 500.0, "Losartan": 25.0, "Latanoprost": 1.0, "Water": 14, "Smoothie": 14, "Protein": 14, "Sake": 3.5]

let matchingDescriptionDictionary: Dictionary<String, String> = ["Rosuvastatin": "Cholesterol-lowering medication", "Metformin": "Glucose-lowering medication", "Losartan": "Blood pressure-lowering medication", "Latanoprost": "Eye pressure reduction medication", "Water": "Hydration, kidney function support", "Smoothie": "Nutrient-rich beverage", "Protein": "Essential amino acid supplement", "Sake": "Japanese rice alcoholic beverage"]


let matchingFrequencyDictionary: Dictionary<String, String> = ["Rosuvastatin": "Once daily", "Metformin": "twice daily", "Losartan": "Once daily", "Latanoprost": "Once daily, evening", "Water": "Six times daily", "Smoothie": "Once daily", "Protein": "Once daily", "Sake": "Once daily"]

public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

func compareDateComponents(_ date1: Date) -> Bool {
    // date 2 should be the reference
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Helper")
    logger.info("date1: \(date1)" )
    return Calendar.autoupdatingCurrent.isDateInToday(date1)
}
