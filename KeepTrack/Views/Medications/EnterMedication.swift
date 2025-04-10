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
        logger.info("Today's active med goals: \(todaysGoals)")
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
         
        // get the medications taken by this time
        // get the medication goals, if any, by this time
        // for each medication, if its being taken before the goal(there may be several), then its a medication taken as goal met.
        // another way of looking at this is if the number of instances of that med type + 1 is equal to or greater than the goal instances, then it is goal met
        
        var result: Bool = false
        
        let goalsAITime = self.getTodaysMedicationGoalsInTime().sorted(by: {$0.startDate ?? Date() < $1.startDate ?? Date()})  // active goals in time
        result = goalsAITime.count <= getTodaysMeds().count + 1
            // adding one as this med is yet to be added into history
        result ? logger.info("Meds intake greater than goals!!!") : logger.info("Meds intake less than goals")
        return result
    }
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Enter medication")
                Picker("Select Type", selection: $medicationName) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }

                Button("Add") {
                        logger.info("Adding medication \(medicationName)")
                        medicationStore.addMedicationWithNameAndGoalmet(name: medicationName, goalmet: isMedicationGoalMet())
                        dismiss()
                }.disabled(medicationName.isEmpty)
            }
            .padding(.horizontal)
            Spacer()
        }
        .environment(medicationStore)
        .environment(medGoals)
    }
}

#Preview {
    EnterMedication()
        .environment(MedicationStore())
        .environment(MedGoals())
}
