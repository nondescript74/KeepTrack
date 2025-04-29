//
//  GoalFullView.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/15/25.
//

import SwiftUI
import OSLog

struct GoalFullView: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "GoalFullView")
    
    @Environment(CommonGoals.self) var goals
    @Environment(\.dismiss) var dismiss
    
    var goal:CommonGoal
    
    @State fileprivate var dates: [Date]
    @State fileprivate var isActive: Bool
    @State fileprivate var isCompleted: Bool
    
    init(goal:CommonGoal) {
        self.goal = goal
        self.isActive = goal.isActive
        self.isCompleted = goal.isCompleted
        self.dates = goal.dates
    }
    
    fileprivate func getMatchingDesription() -> String {
        return matchingDescriptionDictionary[self.goal.name] ?? "no description"
    }
    
    fileprivate func getMatchingUnits() -> String {
        return matchingUnitsDictionary[self.goal.name]  ?? "no units"
    }
    
    fileprivate func getMatchingAmounts() -> Double {
        let myReturnValue: Double = matchingAmountDictionary[self.goal.name] ?? 0.0
        return myReturnValue
    }
    
    fileprivate func getMatchingFrequency() -> String {
        return matchingFrequencyDictionary[self.goal.name] ?? "no frequency"
    }
    
    fileprivate func getFormattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:MM a"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack {
            Text("Edit this Goal")
                .font(.title)
                .foregroundStyle(Color.black)
            
            Text(goal.name)
                .font(.subheadline)
            HStack {
                Text(getMatchingAmounts().description)
                Text(getMatchingUnits())
                Text(getMatchingFrequency())
            }
            
            Text(goal.isActive ? "Active" : "Inactive")
            Text(goal.isCompleted ? "Completed" : "Incomplete")
                .padding(.bottom)
            
            VStack {
                HStack {
                    Text("Name")
                    Text(self.goal.name)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Dosage: ")
                    Text(getMatchingAmounts().description)
                    Spacer()
                    Text("Units: ")
                    Text(getMatchingUnits())
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Times")
                     
                    ForEach(goal.dates, id: \.self) { adate in
                        Text(getFormattedDate(adate))
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Toggle("Is Active", isOn: $isActive)
                    Spacer()
                    Toggle("Is Completed", isOn: $isCompleted)
                }
                .padding([.horizontal, .bottom])
            }
            
            Button("Change Goal", action: {
                logger.info("Deleting goal with id \(self.goal.id)")
                goals.removeGoalAtId(uuid: self.goal.id)
                let savedUUID = self.goal.id
                
                let goal = CommonGoal(id: savedUUID, name: self.goal.name, description: getMatchingDesription(), dates: self.dates, isActive: self.isActive, isCompleted: self.isCompleted, dosage: getMatchingAmounts(), units: getMatchingUnits(), frequency: getMatchingFrequency())
                
                goals.addGoal(goal: goal)
                logger.info("added new goal")
                dismiss()
            })
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(style: StrokeStyle(lineWidth: 2)))
            Spacer()
        }
        .environment(goals)
    }
}

#Preview {
    let goal = CommonGoal(id: UUID(), name: "Metformin", description: matchingDescriptionDictionary["Metformin"] ?? "no description", dates: [Date(), Date().addingTimeInterval(60 * 60 * 2)], isActive: true, isCompleted: false, dosage: matchingAmountDictionary["Metformin"] ?? 0.0, units: matchingUnitsDictionary["Metformin"] ?? "fluid ounces", frequency: matchingFrequencyDictionary["Metformin"] ?? "twice a day")
    GoalFullView(goal: goal)
        .environment(CommonGoals())
}

