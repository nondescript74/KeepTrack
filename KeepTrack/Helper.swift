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

let matchingUnitsDictionary: Dictionary<String, String> = ["Rosuvastatin": "mg", "Metformin": "mg", "Losartan": "mg", "Latanoprost": "drops", "Water": "fluid ounces", "Smoothie": "fluid ounces", "Protein": "g", "Sake": "fluid ounces", "Magnesium Glycinate": "mg", "Vitamin D3": "IU"]


let matchingAmountDictionary: Dictionary<String, Double> = ["Rosuvastatin": 20.0, "Metformin": 500.0, "Losartan": 25.0, "Latanoprost": 1.0, "Water": 14, "Smoothie": 14, "Protein": 14, "Sake": 3.5, "Magnesium Glycinate": 200.0, "Vitamin D3": 500.0]

let matchingDescriptionDictionary: Dictionary<String, String> = ["Rosuvastatin": "Cholesterol-lowering medication", "Metformin": "Glucose-lowering medication", "Losartan": "Blood pressure-lowering medication", "Latanoprost": "Eye pressure reduction medication", "Water": "Hydration, kidney function support", "Smoothie": "Nutrient-rich beverage", "Protein": "Essential amino acid supplement", "Sake": "Japanese rice alcoholic beverage", "Magnesium Glycinate": "Muscle relaxation and nerve function support", "Vitamin D3": "Mind and Immune function support"]


let matchingFrequencyDictionary: Dictionary<String, String> = ["Rosuvastatin": "Once daily", "Metformin": "twice daily", "Losartan": "Once daily", "Latanoprost": "Once daily, evening", "Water": "Six times daily", "Smoothie": "Once daily", "Protein": "Once daily", "Sake": "Once daily", "Magnesium Glycinate": "Once daily", "Vitamin D3": "Once daily"]

public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

func isGoalMet(goal: CommonGoal, previous: Int) -> Bool {
    // previous is the count of previous intake
    if goal.dates.isEmpty {
        logger.info("empty: isGoalMet result is true")
        return true
    }
    var calendar = Calendar.autoupdatingCurrent
    calendar.timeZone =  .current
    let currentDateTime = Date.now
    let dateComponentsNow = calendar.dateComponents([.hour, .minute, .second], from: currentDateTime)
    
    let previousGoalDates: [Date] = goal.dates.compactMap({$0 as Date}).filter({calendar.dateComponents([.hour, .minute, .second], from: $0).hour! < dateComponentsNow.hour! || calendar.dateComponents([.hour, .minute, .second], from: $0).hour! == dateComponentsNow.hour! && (calendar.dateComponents([.hour, .minute, .second], from: $0).minute! < dateComponentsNow.minute!)})
    
    let remainingGoalDates: [Date] = goal.dates.compactMap({$0 as Date}).filter({calendar.dateComponents([.hour, .minute, .second], from: $0).hour! >= dateComponentsNow.hour! || calendar.dateComponents([.hour, .minute, .second], from: $0).hour! == dateComponentsNow.hour! && (calendar.dateComponents([.hour, .minute, .second], from: $0).minute! >= dateComponentsNow.minute!)})
    
    if remainingGoalDates.isEmpty {
        logger.info("no remaining dates: isGoalMet result is true")
        return true
    }
    
    let firstRemaingGoalDate: Date = remainingGoalDates.first!
    let dateComponentsFirst: DateComponents = calendar.dateComponents([.hour, .minute, .second], from: firstRemaingGoalDate)
    
    if previousGoalDates.isEmpty && previous > 0   {
        // no previous dates and already have intake greater than 0, so this one is also met
        logger.info("no previous dates and already have intake greater than 0, so this one is also met: isGoalMet result is true")
        return true
    }
    
    if !previousGoalDates.isEmpty && previous + 1 > previousGoalDates.count {
        logger.info( "previous intake and this one is greater than previousGoalDates.count: isGoalMet result is true" )
        return true
    }
    
    if !previousGoalDates.isEmpty && previous + 1 < previousGoalDates.count {
        logger.info( "previous intake and this one is less than previousGoalDates.count: isGoalMet result is false" )
        return false
    }
    
    var myResult: Bool = false
    
    if previousGoalDates.count == previous {
        // all previous goals == number of intake so check this one
        myResult = dateComponentsNow.hour! < dateComponentsFirst.hour! ? true : dateComponentsNow.hour! == dateComponentsFirst.hour! && dateComponentsNow.minute! <= dateComponentsFirst.minute!
        logger.info("all previous goals == number of intake so check this one: isGoalMet result is \(myResult)")
    }
    return myResult
}


func matchingDateArray(name: String, startDate: Date) -> [Date] {
    var datesArray: [Date] = [startDate]
    if name.lowercased( ).contains( "water" ) {
        datesArray.append( Calendar.current.date(byAdding: .hour, value: 2, to: startDate)! )
        datesArray.append( Calendar.current.date(byAdding: .hour, value: 4, to: startDate)! )
        datesArray.append( Calendar.current.date(byAdding: .hour, value: 6, to: startDate)! )
        datesArray.append( Calendar.current.date(byAdding: .hour, value: 8, to: startDate)! )
        datesArray.append( Calendar.current.date(byAdding: .hour, value: 10, to: startDate)! )
    }
    if name.lowercased( ).contains( "metformin" ) {
        datesArray.append( Calendar.current.date(byAdding: .hour, value: 8, to: startDate)! )
    }
    return datesArray
}
