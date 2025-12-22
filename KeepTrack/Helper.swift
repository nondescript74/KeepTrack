//
//  Helper.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import Foundation
import SwiftUI
import OSLog

let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Helper")

let colors: [Color] = [.orange, .yellow, .cyan, .indigo, .purple, .pink, .teal, .mint, .brown, .green, .red, .blue, .orange, .pink, .red, .blue, .yellow, .green, .indigo, .purple, .cyan, .mint, .brown, .teal, .orange, .yellow, .cyan, .indigo, .purple, .pink, .teal, .mint, .brown, .green, .red, .blue, .orange, .pink, .red, .blue, .yellow, .green, .indigo, .purple, .cyan, .mint, .brown, .teal, .orange, .yellow, .cyan, .indigo, .purple, .pink, .teal, .mint, .brown, .green, .red, .blue, .orange, .pink, .red, .blue, .yellow, .green, .indigo, .purple, .cyan, .mint, .brown, .teal]

enum frequency: String, CaseIterable {
    case daily
    case twiceADay
    case threeTimesADay
    case fourTimesADay
    case sixTimesADay
    case weekly
    case twiceWeekly
    case threeTimesWeekly
    case fourTimesWeekly
    case monthly
    case twiceMonthly
    case threeTimesMonthly
    case none
}

extension frequency {
    var displayName: String {
        switch self {
        case .daily: return "Once Daily"
        case .twiceADay: return "Twice a Day"
        case .threeTimesADay: return "Three Times a Day"
        case .fourTimesADay: return "Four Times a Day"
        case .sixTimesADay: return "Six Times a Day"
        case .weekly: return "Weekly"
        case .twiceWeekly: return "Twice Weekly"
        case .threeTimesWeekly: return "Three Times Weekly"
        case .fourTimesWeekly: return "Four Times Weekly"
        case .monthly: return "Monthly"
        case .twiceMonthly: return "Twice Monthly"
        case .threeTimesMonthly: return "Three Times Monthly"
        case .none: return "None"
        }
    }
}

enum units: String, CaseIterable {
    case ml
    case tsp
    case tbsp
    case cups
    case fluidOunces
    case grams
    case mg
    case drop
    case pounds
    case killograms
    case IU
    case none
    case piece
}

extension units {
    var displayName: String {
        switch self {
        case .ml: return "Milliliters (ml)"
        case .tsp: return "Teaspoon (tsp)"
        case .tbsp: return "Tablespoon (tbsp)"
        case .cups: return "Cups"
        case .fluidOunces: return "Fluid Ounces (fl oz)"
        case .grams: return "Grams (g)"
        case .mg: return "Milligrams (mg)"
        case .drop: return "Drop(s)"
        case .pounds: return "Pounds (lb)"
        case .killograms: return "Kilograms (kg)"
        case .IU: return "International Units (IU)"
        case .piece: return "Piece(s)"
        case .none: return "None"
        }
    }
}

public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

func getHour(from date: Date) -> Int {
    var calendar = Calendar.current
    calendar.timeZone = .current
    let hour = calendar.component(.hour, from: date)
    return hour
}

func getMinute(from date: Date) -> Int {
    var calendar = Calendar.current
    calendar.timeZone = .current
    let minute = calendar.component(.minute, from: date)
    return minute
}

func hourForDate(_ date: Date) -> Int {
    var calendar = Calendar.autoupdatingCurrent
    calendar.timeZone = .current
    let components = calendar.dateComponents([.hour], from: date)
    return components.hour ?? 0
}

func minuteForDate(_ date: Date) -> Int {
    var calendar = Calendar.autoupdatingCurrent
    calendar.timeZone = .current
    let components = calendar.dateComponents([.minute], from: date)
    return components.minute ?? 0
}

func isItAM(date: Date) -> Bool {
    return hourForDate(date) >= 0 && hourForDate(date) < 12
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
    logger.info("first remaining date: \(String(describing: remainingGoalDatesFirst))")  // if there are any remaining dates, may be nil
    
    let previousIntake:Int = previous
    logger.info( "previous intake: \(previousIntake)")  // how many were taken before this one
    
    let dateNowComponents: DateComponents = calendar.dateComponents([.hour, .minute, .second], from: Date.now)  // the date to use for the current intake
    logger.info("date now components: \(dateNowComponents)")
    
    var myResult: Bool = false  // accumulating result
    
    let goalCantBeMet: Bool = !previousGoalDates.isEmpty && previousIntake < previousGoalDates.count  // previous goals were not met yet
    logger.info( "goal cant be met: \(goalCantBeMet)")
    if goalCantBeMet { return false }  // return now as no other condition required
    
    let isGoalMet_no_goals: Bool = goalDates.isEmpty  // there are no goals so goal is met set to true
    logger.info( "no goals: \(isGoalMet_no_goals)")
    
    let isGoalMet_no_more_goals: Bool = remainingGoalDatesFirst == nil || remainingGoalDates.isEmpty ? true : false  // there are no more goals, so set to true
    logger.info( "no more goals: \(isGoalMet_no_more_goals)")
    
    let isGoalMet_with_previous_intake: Bool = previousGoalDates.isEmpty && previousIntake > 0  // no previous dates and already have intake greater than 0, so this one is also met
    logger.info( "with previous intake: \(isGoalMet_with_previous_intake)")
    
    let isGoalMet_with_previous_goals_equal_intake_plus_one: Bool = !previousGoalDates.isEmpty && previousGoalDates.count == previousIntake + 1  // previous intake plus this one equals number of goals so set to true
    logger.info( "previous goals equal intake plus one: \(isGoalMet_with_previous_goals_equal_intake_plus_one)")
    
    let isGoalMet_with_previous_intake_and_previous_goals: Bool = !previousGoalDates.isEmpty && previousIntake + 1 > previousGoalDates.count  // with this one, intake is more than goals
    logger.info( "with previous intake and goals: \(isGoalMet_with_previous_intake_and_previous_goals)")
    
    if remainingGoalDatesFirst != nil {  // there are remaining goals, must do comparing by hour and minute
        let remainingGoalDatesFirstComponents: DateComponents = calendar.dateComponents([.hour, .minute, .second], from: remainingGoalDatesFirst!)
        logger.info("first remaining date components: \(remainingGoalDatesFirstComponents)")
        
        let isGoalMet_with_first_remaining_using_hour: Bool = !remainingGoalDates.isEmpty && remainingGoalDatesFirstComponents.hour! > dateNowComponents.hour!
        logger.info("met with first remaining goal using hour only: \(isGoalMet_with_first_remaining_using_hour)")
        
        let isGoalMet_with_first_remaining_using_hour_n_minute: Bool = !remainingGoalDates.isEmpty && remainingGoalDatesFirstComponents.hour! == dateNowComponents.hour! && remainingGoalDatesFirstComponents.minute! >= dateNowComponents.minute!
        logger.info("met with first remaining goal using hour_n_minute: \(isGoalMet_with_first_remaining_using_hour_n_minute)")
        
        let isGoalMet_with_first_remaining_using_hour_n_minute_n_second: Bool = !remainingGoalDates.isEmpty && remainingGoalDatesFirstComponents.hour! == dateNowComponents.hour! && remainingGoalDatesFirstComponents.minute! == dateNowComponents.minute! && remainingGoalDatesFirstComponents.second! >= dateNowComponents.second!
        logger.info("met with first remaining goal using hour_n_minute_n_second: \(isGoalMet_with_first_remaining_using_hour_n_minute_n_second)")
        
        myResult = isGoalMet_no_goals || isGoalMet_no_more_goals || isGoalMet_with_previous_intake || isGoalMet_with_previous_goals_equal_intake_plus_one || isGoalMet_with_previous_intake_and_previous_goals || isGoalMet_with_first_remaining_using_hour || isGoalMet_with_first_remaining_using_hour_n_minute || isGoalMet_with_first_remaining_using_hour_n_minute_n_second
        
        logger.info("result: \(myResult)")
    } else {  // there are no more remaining dates so use only the conditions that apply in that case
        myResult = isGoalMet_no_goals || isGoalMet_no_more_goals || isGoalMet_with_previous_intake || isGoalMet_with_previous_goals_equal_intake_plus_one || isGoalMet_with_previous_intake_and_previous_goals
        
    }
    return myResult
}


func matchingDateArray(name: String, startDate: Date, useUserTime: Bool = false) -> [Date] {
    var calendar = Calendar.current
    calendar.timeZone = .current
    
    // Use either the user-specified time or normalize to their chosen hour
    let normalizedStartDate: Date
    if useUserTime {
        // Keep the user's selected time as-is
        normalizedStartDate = startDate
    } else {
        // Extract just the hour and minute from user's selection, apply to today
        var components = calendar.dateComponents([.year, .month, .day], from: Date.now)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: startDate)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = 0
        normalizedStartDate = calendar.date(from: components) ?? startDate
    }
    
    var datesArray: [Date] = [normalizedStartDate]
    
    let myIntakeTypeUrl = Bundle.main.url(forResource: "intakeTypes", withExtension: "json")!
    let myIntakeTypeData = try! Data(contentsOf: myIntakeTypeUrl)
    let myIntakeTypeArray = try! JSONDecoder().decode([IntakeType].self, from: myIntakeTypeData).sorted { $0.name < $1.name }
    
    let mySpecificIntakeTypeIndex = myIntakeTypeArray.firstIndex { $0.name.lowercased() == name.lowercased() } ?? 0
    let mySpecificIntakeType = myIntakeTypeArray[mySpecificIntakeTypeIndex]
    
    let myFrequency = mySpecificIntakeType.frequency
    
    // Calculate subsequent doses spread across a 12-hour waking period from the start time
    switch myFrequency {
    case frequency.daily.rawValue:
        break
    case frequency.twiceADay.rawValue:
        // Start time and 12 hours later
        datesArray.append(calendar.date(byAdding: .hour, value: 12, to: normalizedStartDate)!)
    case frequency.threeTimesADay.rawValue:
        // Start time, +6 hours, +12 hours
        datesArray.append(calendar.date(byAdding: .hour, value: 6, to: normalizedStartDate)!)
        datesArray.append(calendar.date(byAdding: .hour, value: 12, to: normalizedStartDate)!)
    case frequency.fourTimesADay.rawValue:
        // Start time, +4 hours, +8 hours, +12 hours
        datesArray.append(calendar.date(byAdding: .hour, value: 4, to: normalizedStartDate)!)
        datesArray.append(calendar.date(byAdding: .hour, value: 8, to: normalizedStartDate)!)
        datesArray.append(calendar.date(byAdding: .hour, value: 12, to: normalizedStartDate)!)
    case frequency.sixTimesADay.rawValue:
        // Start time, +2.5h, +5h, +7.5h, +10h, +12h
        datesArray.append(calendar.date(byAdding: .minute, value: 150, to: normalizedStartDate)!)  // +2.5 hours
        datesArray.append(calendar.date(byAdding: .minute, value: 300, to: normalizedStartDate)!)  // +5 hours
        datesArray.append(calendar.date(byAdding: .minute, value: 450, to: normalizedStartDate)!)  // +7.5 hours
        datesArray.append(calendar.date(byAdding: .minute, value: 600, to: normalizedStartDate)!)  // +10 hours
        datesArray.append(calendar.date(byAdding: .minute, value: 720, to: normalizedStartDate)!)  // +12 hours
    default:
        break
    }
    
    return datesArray
}
