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
    @State var amount: Double = amounts.sorted(by: {$0 < $1})[12]
    @State var frequency: String = frequencies.sorted(by: {$0 < $1})[1]
    @State var unit: String = units.sorted(by: {$0 < $1})[1]
    
    
    private func getToday() -> [CommonEntry] {
        let todays = store.history.filter { Calendar.current.isDateInToday($0.date) }
        return  todays
    }
    
    
    fileprivate func getTodaysGoals() -> [CommonGoal] {
        let todaysGoals = goals.goals.filter { $0.isActive}
        logger.info("Today's active med goals: \(todaysGoals)")
        return todaysGoals
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
            
            if (hourGoal! < hourNow!) {
                todaysGoalsActiveInTime.append(agoal)
            } else if (hourGoal! == hourNow!) && (minuteGoal! <= minuteNow!) {
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
        
        let goalsAITime = self.getTodaysGoalsInTime()  // active goals in time
        result = goalsAITime.count <= getTodaysGoals().count + 1
        // adding one as this is yet to be added into history
        result ? logger.info("Intake greater than goals!!!") : logger.info("Intake less than goals")
        return result
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
                Picker("Select amount", selection: $amount) {
                    ForEach(amounts.sorted(by: {$0 < $1}), id: \.self) {
                        Text($0.description)
                    }
                }
            }
            HStack {
                Text("Units")
                Picker("Select unit", selection: $unit) {
                    ForEach(units.sorted(by: {$0 < $1}), id: \.self) {
                        Text($0)
                            .font(.subheadline)
                    }
                }
            }
            Button("Add") {
                logger.info("Adding intake  \(name)")
                store.addEntry(entry: CommonEntry(id: UUID(), date: Date(), units: unit, amount: amount, name: name, goalMet: isGoalMet())
                )
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
