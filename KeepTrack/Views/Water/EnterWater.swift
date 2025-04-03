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
    
    fileprivate func getTodaysWater() -> [WaterEntry] {
        let todays = water.waterHistory.filter { Calendar.current.isDateInToday($0.date) }
            .filter { $0.units > 0 }
        logger.info("Todays water intake : \(todays)")
        return todays
    }
    
    fileprivate func getTodaysGoals() -> [Goal] {
        let todaysGoals = goals.goals.filter { $0.isActive ?? false}
        logger.info("Today's active goals: \(todaysGoals)")
        return todaysGoals
    }
    
    fileprivate func isGoalMet() -> Bool {
        return getTodaysWater().count >= getTodaysGoals().count
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Enter water intake")
                Picker("Water Intake", selection: $waterIntake) {
                    ForEach(1...3, id: \.self) {
                        Text("\($0)")
                    }
                }
                .onChange(of: waterIntake) { newValue in
                    logger.info("waterIntake changed to \(newValue)")
                }
                
                Spacer()
                
                
                Button("Add") {
                    water.addWater(waterIntake, goalmet: isGoalMet())
                    dismiss()
                }
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
