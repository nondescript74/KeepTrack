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
    var calendar = Calendar.autoupdatingCurrent
    calendar.timeZone =  .current

    let goalDates: [Date] = goal.dates.compactMap({$0 as Date})

    let hourNow: Int = calendar.dateComponents([.hour, .minute, .second], from: Date.now).hour!
    let minuteNow: Int = calendar.dateComponents([.hour, .minute, .second], from: Date.now).minute!


    let previousGoalDates: [Date] = goalDates.filter({
        calendar.dateComponents([.hour, .minute, .second], from: $0).hour! < hourNow
        ||
        calendar.dateComponents([.hour, .minute, .second], from: $0).hour! == hourNow
        &&
        (calendar.dateComponents([.hour, .minute, .second], from: $0).minute! <= minuteNow)})

    let remainingGoalDates: [Date] = goalDates.filter({
        calendar.dateComponents([.hour, .minute, .second], from: $0).hour! > hourNow
        ||
        calendar.dateComponents([.hour, .minute, .second], from: $0).hour! == hourNow
        &&
        (calendar.dateComponents([.hour, .minute, .second], from: $0).minute! >= minuteNow)})
    
    
    logger.info("goal name: \(goal.name)")
    let remainingGoalDatesFirst: Date? = remainingGoalDates.first
    logger.info("first remaining date: \(String(describing: remainingGoalDatesFirst))")

    let previousIntake:Int = previous
    logger.info( "previous intake: \(previousIntake)")

    let previous_goals_equal_intake_plus_one: Bool = !previousGoalDates.isEmpty && previousGoalDates.count == previousIntake + 1
    logger.info( "previous goals equal intake plus one: \(previous_goals_equal_intake_plus_one)")
    
    var myResult: Bool = false

    let isGoalMet_no_goals_Stop: Bool = goalDates.isEmpty
    logger.info( "no goals: \(isGoalMet_no_goals_Stop)")

    let isGoalMet_no_more_goals_Stop: Bool = remainingGoalDates.isEmpty ? true : false
    // if there are no more goals
    logger.info( "no more goals: \(isGoalMet_no_more_goals_Stop)")
    
    let isGoalMet_with_previous_intake_Stop: Bool = previousGoalDates.isEmpty && previousIntake > 0
    // no previous dates and already have intake greater than 0, so this one is also met
    logger.info( "with previous intake: \(isGoalMet_with_previous_intake_Stop)")

    let isGoalMet_with_previous_intake_and_goals_Stop: Bool = !previousGoalDates.isEmpty && previousIntake + 1 > previousGoalDates.count
    logger.info( "with previous intake and goals: \(isGoalMet_with_previous_intake_and_goals_Stop)")

    let isGoalMet_with_first_remaining_Stop: Bool = previous_goals_equal_intake_plus_one && !remainingGoalDates.isEmpty && remainingGoalDatesFirst! >= Date.now
    logger.info("with first remaining goal: \(isGoalMet_with_first_remaining_Stop)")
    
    myResult = isGoalMet_no_goals_Stop || isGoalMet_no_more_goals_Stop || isGoalMet_with_previous_intake_Stop || isGoalMet_with_previous_intake_and_goals_Stop || isGoalMet_with_first_remaining_Stop
    logger.info("result: \(myResult)")

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
