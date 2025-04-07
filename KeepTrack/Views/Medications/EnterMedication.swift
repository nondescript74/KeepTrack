//
//  EnterMedication.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/23/25.
//

import SwiftUI
import OSLog

struct EnterMedication: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterMedication")
    @Environment(MedicationStore.self) var medicationStore
    @Environment(MedGoals.self) var medGoals
    @Environment(\.dismiss) var dismiss
    @State var medicationName: String = ""
    
    fileprivate let types: [String] = ["Metformin", "Losartan", "Latanoprost", "Rosuvastatin"]
    
    fileprivate func getTodaysMeds() -> [MedicationEntry] {
        let todays = medicationStore.medicationHistory.filter { Calendar.current.isDateInToday($0.date) }
        logger.info("Todays medication intake : \(todays)")
        return todays
    }
    
    fileprivate func getTodaysMedicationGoals() -> [MedicationGoal] {
        let todaysGoals = medGoals.medGoals.filter { $0.isActive ?? false}
        logger.info("Today's active goals: \(todaysGoals)")
        return todaysGoals
    }
    
    fileprivate func getTodaysMedicationGoalsInTime() -> [MedicationGoal] {
        let todaysGoalsActive = getTodaysMedicationGoals()
        var todaysGoalsActiveInTime: [MedicationGoal] = []
        let currentDateTime = Date()
        let componentsNow = Calendar.current.dateComponents([.hour,.minute], from: currentDateTime)
        let hourNow = componentsNow.hour
        let minuteNow = componentsNow.minute
        
        for agoal in todaysGoalsActive {
            let componentsGoal = Calendar.current.dateComponents([.hour,.minute], from: agoal.endDate ?? Date())
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
        logger.info("getTodaysMedicationGoalsActiveInTime is \(todaysGoalsActiveInTime)")
        return todaysGoalsActiveInTime
    }
    
    fileprivate func isMedicationGoalMet() -> Bool {
        // get the time
        // get the number of liquid drunk by this time
        // get the number of liquid goals by this time
        // if the number of liquid drunk so far plus this one is greater than the goals so far today, return true, else false
        var result: Bool = false
        
        let goalsAITime = self.getTodaysMedicationGoalsInTime().sorted(by: {$0.endDate ?? Date() < $1.endDate ?? Date()})  // active goals in time
        result = goalsAITime.count <= getTodaysMeds().count + 1
            // adding one as this med is yet to be added into history
        result ? logger.info("Meds intake greater than goals!!!") : logger.info("Meds intake less than goals")
        return result
    }
    
    var body: some View {
        VStack {
            Text("Enter medication")
            HStack {
                Picker("Select Type", selection: $medicationName) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }

                Button("Add") {
//                    if !medicationName.isEmpty {
                        logger.info("Adding medication \(medicationName)")
                        medicationStore.addMedicationWithNameAndGoalmet(name: medicationName, goalmet: isMedicationGoalMet())
                        dismiss()
//                    }
                }.disabled(medicationName.isEmpty)
            }
            .padding(.horizontal)
            .environment(medicationStore)
            Spacer()
        }
    }
}

#Preview {
    EnterMedication()
        .environment(MedicationStore())
}
