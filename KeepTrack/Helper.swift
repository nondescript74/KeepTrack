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

let colors: [Color] = [.orange, .yellow, .blue, .indigo, .purple, .pink, .cyan]

public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
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

