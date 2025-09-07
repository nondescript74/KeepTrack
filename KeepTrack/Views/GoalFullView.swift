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
    @EnvironmentObject var cIntakeTypes: CurrentIntakeTypes
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
                Text(cIntakeTypes.intakeTypeArray.first(where: {$0.name == self.goal.name})?.amount.description ?? 0.description)
                Text(cIntakeTypes.intakeTypeArray.first(where: {$0.name == self.goal.name})?.unit ?? "unit")
                Text(cIntakeTypes.intakeTypeArray.first(where: {$0.name == self.goal.name})?.frequency ?? frequency.none.rawValue)
            }
            
            Text(goal.isActive ? "Active" : "Inactive")
                .padding(.bottom)
            
            VStack {
                HStack {
                    Text("Name")
                    Text(self.goal.name)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Dosage: ")
                    Text(cIntakeTypes.intakeTypeArray.first(where: {$0.name == self.goal.name})?.amount.description ?? 0.description)
                    Spacer()
                    Text("Units: ")
                    Text(cIntakeTypes.intakeTypeArray.first(where: {$0.name == self.goal.name})?.unit ?? "unit")
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
                }
                .padding([.horizontal, .bottom])
                
                
                
                Button("Change Goal", action: {
                    let savedUUID = self.goal.id
                    
                    let goal = CommonGoal(id: savedUUID, name: self.goal.name, description: cIntakeTypes.intakeTypeArray.first(where: {$0.name == self.goal.name})?.descrip ?? "no description", dates: self.dates, isActive: self.isActive, isCompleted: self.isCompleted, dosage: cIntakeTypes.intakeTypeArray.first(where: {$0.name == self.goal.name})?.amount ?? 0, units: cIntakeTypes.intakeTypeArray.first(where: {$0.name == self.goal.name})?.unit ?? "no unit", frequency: cIntakeTypes.intakeTypeArray.first(where: {$0.name == self.goal.name})?.frequency ?? frequency.none.rawValue)
                    
                    goals.addGoal(goal: goal)
                    logger.info("added new goal")
                    dismiss()
                })
                .foregroundStyle(Color.blue)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(style: StrokeStyle(lineWidth: 2)))
                Spacer()
            }
        }
        .environment(goals)
    }
}

#Preview {
    let goal = CommonGoal(id: UUID(), name: "Metformin", description: "Sugar control", dates: [Date(), Date().addingTimeInterval(60 * 60 * 2)], isActive: true, isCompleted: false, dosage: 400, units: "mg", frequency: frequency.twiceADay.rawValue)
    GoalFullView(goal: goal)
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
