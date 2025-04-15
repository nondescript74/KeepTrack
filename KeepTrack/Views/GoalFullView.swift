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
    @State fileprivate var descrip: String
    @State fileprivate var dosage: Int
    @State fileprivate var frequency: String
    @State fileprivate var dates: [Date]
    @State fileprivate var isActive: Bool
    @State fileprivate var isCompleted: Bool
    
    init(goal:CommonGoal) {
        self.goal = goal
        self.name = goal.name
        self.dosage = goal.dosage
        self.frequency = goal.frequency
        self.isActive = goal.isActive
        self.isCompleted = goal.isCompleted
        self.dates = goal.dates
        self.descrip = goal.description
    }

    var body: some View {
        VStack {
            Section(header: Text("Goal Details").font(.headline)) {
                Text(goal.name)
                    .font(.subheadline)
                Text(goal.dosage.description)
                    .font(.caption)
                Text(goal.isActive ? "Active" : "Inactive")
                Text(goal.isCompleted ? "Completed" : "Incomplete")
                Text((frequency.lowercased().contains("twice") ? "Take twice a day" : frequency.lowercased().contains("three") ? "Take three times a day" : frequency.lowercased().contains("six") ? "Take six times a day" : "Take once a day"))
                
            }
            .padding(.bottom)
//            
//            Spacer()
//            
            VStack {
                Text("Edit this Medication Goal")
                    .font(.title)
                    .foregroundStyle(Color.black)
                HStack {
                    Text("Name")
                    TextField("Name", text: $name)
                }
                HStack {
                    Text("Dosage")
                    TextField("Dosage", value: $dosage, format: .number)
                }
                
                if frequency.lowercased().contains("once daily") {
                    VStack(alignment: .leading) {
                        DatePicker("Start Time", selection: $dates[0].animation(.default), displayedComponents: .hourAndMinute)
                    }
                    .padding(.horizontal)
                } else if frequency.lowercased().contains("twice") {
                    VStack(alignment: .leading) {
                        DatePicker("Start Time 1", selection: $dates[0].animation(.default), displayedComponents: .hourAndMinute)
                        DatePicker("Start Time 2", selection: $dates[1].animation(.default), displayedComponents: .hourAndMinute)
                    }
                    .padding(.horizontal)
                } else if frequency.lowercased().contains("three") {
                    VStack(alignment: .leading) {
                        DatePicker("Start Time 1", selection: $dates[0].animation(.default), displayedComponents: .hourAndMinute)
                        DatePicker("Start Time 2", selection: $dates[1].animation(.default), displayedComponents: .hourAndMinute)
                        DatePicker("Start Time 3", selection: $dates[2].animation(.default), displayedComponents: .hourAndMinute)
                    }
                    .padding(.horizontal)
                } else if frequency.lowercased().contains("six") {
                    VStack(alignment: .leading) {
                        DatePicker("Start Time 1", selection: $dates[0].animation(.default), displayedComponents: .hourAndMinute)
                        DatePicker("Start Time 2", selection: $dates[1].animation(.default), displayedComponents: .hourAndMinute)
                        DatePicker("Start Time 3", selection: $dates[2].animation(.default), displayedComponents: .hourAndMinute)
                        DatePicker("Start Time 4", selection: $dates[3].animation(.default), displayedComponents: .hourAndMinute)
                        DatePicker("Start Time 5", selection: $dates[4].animation(.default), displayedComponents: .hourAndMinute)
                        DatePicker("Start Time 6", selection: $dates[5].animation(.default), displayedComponents: .hourAndMinute)
                        
                    }
                    .padding(.horizontal)
                }
                
                HStack {
                    Text("Is Active")
                    Toggle("Is Active", isOn: $isActive)
                }
                
                HStack {
                    Text("Is Completed")
                    Toggle("Is Completed", isOn: $isCompleted)
                }
            }
            
            Button("Change Goal", action: {
                logger.info("Deleting goal with id \(self.goal.id)")
                goals.removeGoalAtId(uuid: self.goal.id)
                goals.addGoal(goal: CommonGoal(id: UUID(), name: self.name, description: self.descrip, dates: self.dates, isActive: self.isActive, isCompleted: self.isCompleted, dosage: self.dosage, frequency: self.frequency))
                logger.info("added new goal")
                dismiss()
            })
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(style: StrokeStyle(lineWidth: 2)))
        }
        .environment(goals)
    }
}

#Preview {
    GoalFullView(goal: CommonGoal(id: UUID(), name: "Test Goal", description: "Test Description", dates: [Date()], isActive: true, isCompleted: false, dosage: 1, frequency: "once daily"))
        .environment(CommonGoals())
}

