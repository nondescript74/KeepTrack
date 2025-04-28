//
//  Helper.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import Foundation
import SwiftUI
import OSLog

let types = ["Rosuvastatin", "Metformin", "Losartan", "Latanoprost", "Water", "Smoothie", "Protein", "Sake", "Magnesium Glycinate", "Vitamin D3"].sorted()

let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Helper")

let units: [String] = ["mg", "fluid ounces", "cups", "g", "ozs", "ml", "liters", "pills", "drops", "fluid ounces", "mg", "IU"]

let matchingUnitsDictionary: Dictionary<String, String> = ["Rosuvastatin": "mg", "Metformin": "mg", "Losartan": "mg", "Latanoprost": "drops", "Water": "fluid ounces", "Smoothie": "fluid ounces", "Protein": "g", "sake": "fluid ounces", "Magnesium Glycinate": "mg", "Vitamin D3": "IU"]


let matchingAmountDictionary: Dictionary<String, Double> = ["Rosuvastatin": 20.0, "Metformin": 500.0, "Losartan": 25.0, "Latanoprost": 1.0, "Water": 14, "Smoothie": 14, "Protein": 14, "Sake": 3.5, "Magnesium Glycinate": 200.0, "Vitamin D3": 500.0]

let matchingDescriptionDictionary: Dictionary<String, String> = ["Rosuvastatin": "Cholesterol-lowering medication", "Metformin": "Glucose-lowering medication", "Losartan": "Blood pressure-lowering medication", "Latanoprost": "Eye pressure reduction medication", "Water": "Hydration, kidney function support", "Smoothie": "Nutrient-rich beverage", "Protein": "Essential amino acid supplement", "Sake": "Japanese rice alcoholic beverage", "Magnesium Glycinate": "Muscle relaxation and nerve function support", "Vitamin D3": "Mind and Immune function support"]


let matchingFrequencyDictionary: Dictionary<String, String> = ["Rosuvastatin": "Once daily", "Metformin": "twice daily", "Losartan": "Once daily", "Latanoprost": "Once daily, evening", "Water": "Six times daily", "Smoothie": "Once daily", "Protein": "Once daily", "Sake": "Once daily", "Magnesium Glycinate": "Once daily", "Vitamin D3": "Once daily"]

public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}


func isGoalMet(goal: CommonGoal) -> Bool {
    
    if goal.dates.isEmpty {
        return true
    }
    var calendar = Calendar.autoupdatingCurrent
    calendar.timeZone =  .current
    let currentDateTime = Date.now
    let dateComponentsNow = calendar.dateComponents([.hour, .minute, .second], from: currentDateTime)
    
    let remainingGoalDates: [Date] = goal.dates.compactMap({$0 as Date}).filter({calendar.dateComponents([.hour, .minute, .second], from: $0).hour! >= dateComponentsNow.hour! || calendar.dateComponents([.hour, .minute, .second], from: $0).hour! == dateComponentsNow.hour! && (calendar.dateComponents([.hour, .minute, .second], from: $0).minute! >= dateComponentsNow.minute!)})
    
    if remainingGoalDates.count == 0 {
        return false
    }
    let firstRemaingGoalDate: Date = remainingGoalDates.first!
    let dateComponentsFirst: DateComponents = calendar.dateComponents([.hour, .minute, .second], from: firstRemaingGoalDate)
    
    let result = dateComponentsNow.hour! < dateComponentsFirst.hour! ? true : dateComponentsNow.hour! == dateComponentsFirst.hour! && dateComponentsNow.minute! <= dateComponentsFirst.minute!
    
    logger.info("isGoalMet result: \(result)")
    return result
}
