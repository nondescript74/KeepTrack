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
    
    @State fileprivate var name: String
    @State fileprivate var dates: [Date]
    @State fileprivate var isActive: Bool
    @State fileprivate var isCompleted: Bool
    
    init(goal:CommonGoal) {
        self.goal = goal
        self.name = goal.name
        self.isActive = goal.isActive
        self.isCompleted = goal.isCompleted
        self.dates = goal.dates
    }
    
    fileprivate func getMatchingDesription() -> String {
        return matchingDescriptionDictionary[name] ?? "no description"
    }
    
    fileprivate func getMatchingUnits() -> String {
        return matchingUnitsDictionary[name] ?? "no units"
    }
    
    fileprivate func getMatchingAmounts() -> Double {
        return matchingAmountDictionary[name] ?? 0.0
    }
    
    fileprivate func getMatchingFrequency() -> String {
        return matchingFrequencyDictionary[name] ?? "no frequency"
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
                    TextField("Name", text: $name)
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
                    Spacer()
                    ForEach(goal.dates, id: \.self) { adate in
                        adate.description.isEmpty ? Text("No dates set") : Text(getFormattedDate(adate))
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
                
                let goal = CommonGoal(id: UUID(), name: self.name, description: getMatchingDesription(), dates: self.dates, isActive: self.isActive, isCompleted: self.isCompleted, dosage: getMatchingAmounts(), units: getMatchingUnits(), frequency: getMatchingFrequency())
                
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
    let goal = CommonGoal(id: UUID(), name: "water", description: matchingDescriptionDictionary["water"] ?? "no description", dates: [Date(), Date().addingTimeInterval(60 * 60 * 2)], isActive: true, isCompleted: false, dosage: matchingAmountDictionary["water"] ?? 0.0, units: matchingUnitsDictionary["water"] ?? "drops", frequency: matchingFrequencyDictionary["water"] ?? "once a day")
    GoalFullView(goal: goal)
        .environment(CommonGoals())
}

