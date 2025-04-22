//
//  EnterIntake.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog

struct EnterIntake: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterIntake")
    @Environment(CommonStore.self) var store
    @Environment(CommonGoals.self) var goals
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = types.sorted(by: {$0 < $1})[6]
    @State var frequency: String = frequencies.sorted(by: {$0 < $1})[1]
    
    
    private func getTodaysIntakeForName() -> [CommonEntry] {
        let todays = store.history.filter { Calendar.current.isDateInToday($0.date) }
        return  todays
    }
    
    
    fileprivate func getTodaysGoals() -> [CommonGoal] {
        let todaysGoals = goals.goals.filter { $0.isActive}
        logger.info("Today's active med goals: \(todaysGoals)")
        return todaysGoals
    }
    
    fileprivate func getTodaysGoalsByName() -> [CommonGoal] {
        let todaysGoalsActive = getTodaysGoals()
        var todaysGoalsActiveByName: [CommonGoal] = []
        for agoal in todaysGoalsActive {
            if agoal.name == name {
                todaysGoalsActiveByName.append(agoal)
            }
        }
        logger.info( "Today's active goals for \(name) : \(todaysGoalsActiveByName)")
        return todaysGoalsActiveByName.sorted(by: {$0.dates[0] < $1.dates[0]})
    }
    
    fileprivate func getTodaysGoalsInTime() -> [CommonGoal] {
        let todaysGoalsActive = getTodaysGoals()
        var todaysGoalsActiveInTime: [CommonGoal] = []
        let currentDateTime = Date()
        let componentsNow = Calendar.current.dateComponents([.hour,.minute], from: currentDateTime)
        let hourNow = componentsNow.hour
        let minuteNow = componentsNow.minute
        
        for agoal in todaysGoalsActive {
            let componentsGoal = Calendar.current.dateComponents([.hour,.minute], from: agoal.dates.sorted(by: >)[0])  // ??
            let hourGoal = componentsGoal.hour
            let minuteGoal = componentsGoal.minute
            
            if (hourGoal ?? 1 < hourNow ?? 1) {
                todaysGoalsActiveInTime.append(agoal)
            } else if (hourGoal ?? 1 == hourNow ?? 1) && (minuteGoal ?? 1 <= minuteNow  ?? 1) {
                todaysGoalsActiveInTime.append(agoal)
            }
            // array of timegoals
            // are all of them met, if so return true
        }
        logger.info("getTodaysGoalsActiveInTime is \(todaysGoalsActiveInTime)")
        return todaysGoalsActiveInTime
    }
    
    fileprivate func isGoalMet() -> Bool {
        
        // get the intake taken by this time
        // get the goals, if any, by this time
        // for each intake, if its being taken before the goal(there may be several), then its a intake taken as goal met.
        // another way of looking at this is if the number of instances of that intake type + 1 is equal to or greater than the goal instances, then it is goal met
        
        var result: Bool = false
        let goalsForName = getTodaysGoalsByName()
        let todaysIntakeByName = getTodaysIntakeForName()
        if goalsForName.isEmpty { return true }
        if goalsForName.count > 1 { logger.warning("More than one goal for \(name), using first one") }
        if todaysIntakeByName.isEmpty {
            let goal = goalsForName[0]
            let dateForGoal = goal.dates[0]
            let dateComponentsGoal = Calendar.current.dateComponents([.hour,.minute], from: dateForGoal)
            
            let currentDateTime = Date()
            let componentsNow = Calendar.current.dateComponents([.hour,.minute], from: currentDateTime)
            let hourNow = componentsNow.hour
            let minuteNow = componentsNow.minute
            
            if (hourNow ?? 1 < dateComponentsGoal.hour ?? 1) {
                result = true
            } else if (hourNow ?? 1 == dateComponentsGoal.hour ?? 1 && minuteNow ?? 0 < dateComponentsGoal.minute ?? 0) {
                result = true
            } else {
                result = false
            }
        } else {
            result = false
            let goal = goalsForName[0]
            var dateForGoal = goal.dates[0]
            var dateComponentsGoal = Calendar.current.dateComponents([.hour,.minute], from: dateForGoal)
            // previous intake may have met goals already and is not empty
            let todaysIntakeByNameSorted = getTodaysIntakeForName().sorted { $0.date < $1.date }  // these are all today so no danger of different day
            switch goalsForName[0].dates.count {
            case 0:
                result = true
            case 1:
                let todaysDateComponents = Calendar.current.dateComponents([.hour,.minute], from: todaysIntakeByNameSorted[0].date)
                if todaysDateComponents.hour ?? 0 <= dateComponentsGoal.hour ?? 0 {
                    result = true
                } else {
                    result = false
                }
            case 2, 3, 4, 5:
                break
                
            case 6:
                // water
                break
                
            default:
                break
            }
        }
        
        return result
    }
    
    fileprivate func getMatchingUnit() -> String {
        return matchingUnitsDictionary.first(where: {$0.key == name})?.value ?? ""
    }
    
    fileprivate func getMatchingAmount() -> Double {
        return matchingAmountDictionary.first(where: {$0.key == name})?.value ?? 0
    }
    
    var body: some View {
        VStack {
            Text("Enter intake details")
                .font(.headline)
                .fontWeight(.bold)
            HStack {
                Text("item")
                Picker("Select Type", selection: $name) {
                    ForEach(types.sorted(by: {$0 < $1}), id: \.self) {
                        Text($0)
                    }
                }
            }
            HStack {
                Text("amount")
                Text(getMatchingAmount().formatted())
                Text(getMatchingUnit())
            }
            .padding(.bottom)
            Button("Add") {
                
                let entry = CommonEntry(id: UUID(), date: Date(), units: getMatchingUnit(), amount: getMatchingAmount(), name: name, goalMet: isGoalMet())
                
                store.addEntry(entry: entry)
                
                logger.info("Added intake  \(name) \(getMatchingAmount()) units \(getMatchingUnit())")
                
                
                dismiss()
            }.disabled(name.isEmpty)
            Spacer()
            
        }
        .environment(store)
        .environment(goals)
    }
}

#Preview {
    EnterIntake()
        .environment(CommonStore())
        .environment(CommonGoals())
}
