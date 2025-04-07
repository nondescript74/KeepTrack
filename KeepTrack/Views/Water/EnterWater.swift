//
//  EnterWater.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/18/25.
//

import SwiftUI
import OSLog

struct EnterWater: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterWater")
    @Environment(Water.self) var water
    @Environment(Goals.self) var goals
    @Environment(\.dismiss) var dismiss
    @State var waterIntake: Int = 1
    @State var name: String = "Water"
    @State var amount: Double = 14.0
    
    fileprivate let types: [String] = ["Water", "Smoothie", "Juice", "Milk", "Yoghurt"]
    
    fileprivate func getTodaysWater() -> [WaterEntry] {
        let todays = water.waterHistory.filter { Calendar.current.isDateInToday($0.date) }
        logger.info("Todays water intake : \(todays)")
        return todays
    }
    
    fileprivate func getTodaysGoals() -> [Goal] {
        let todaysGoals = goals.goals.filter { $0.isActive ?? false}
        logger.info("Today's active goals: \(todaysGoals)")
        return todaysGoals
    }
    
    fileprivate func getTodaysGoalsInTime() -> [Goal] {
        let todaysGoalsActive = getTodaysGoals()
        var todaysGoalsActiveInTime: [Goal] = []
        let currentDateTime = Date()
        let componentsNow = Calendar.current.dateComponents([.hour,.minute], from: currentDateTime)
        let hourNow = componentsNow.hour
        let minuteNow = componentsNow.minute
        
        for agoal in todaysGoalsActive {
            let componentsGoal = Calendar.current.dateComponents([.hour,.minute], from: agoal.endDate)
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
        logger.info("todaysGoalsActiveInTime is \(todaysGoalsActiveInTime)")
        return todaysGoalsActiveInTime
    }
    
    fileprivate func isGoalMet() -> Bool {
        // get the time
        // get the number of liquid drunk by this time
        // get the number of liquid goals by this time
        // if the number of liquid drunk so far plus this one is greater than the goals so far today, return true, else false
        var result: Bool = false
        
        let goalsAITime = self.getTodaysGoalsInTime().sorted(by: {$0.endDate < $1.endDate})  // active goals in time
        result = goalsAITime.count <= getTodaysWater().count + 1
            // adding one as this water is yet to be added into history
        result ? logger.info("Intake greater than goals!!!") : logger.info("Intake less than goals")
        return result
    }
    
    var body: some View {
        VStack {
            Text("Enter liquid intake")
            HStack {
                Picker("Select Type", selection: $name) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }
                TextField("Amount", value: $amount, formatter: NumberFormatter())
                Text("oz")
                Spacer()
                Button("Add") {
                    water.addLiquid(amount, goalmet: isGoalMet() , name: name)
                    dismiss()
                }.disabled(amount.isNaN || amount == 0)
            }
            .padding(.horizontal)
            .environment(water)
            .environment(goals)
            Spacer()
        }
    }
}

#Preview {
    EnterWater(waterIntake: 1)
        .environment(Water())
        .environment(Goals())
}
