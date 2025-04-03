//
//  GoalFullView.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/2/25.
//

import SwiftUI
import OSLog

struct GoalFullView: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "GoalFullView")
    @Environment(Goals.self) var goals
    fileprivate var goal:Goal
    @State private var name: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isActive: Bool
    @State private var isCompleted: Bool
    
    init(goal:Goal) {
        self.goal = goal
        self.name = goal.name
        self.description = goal.description
        self.startDate = goal.startDate
        self.endDate = goal.endDate
        self.isActive = goal.isActive ?? false
        self.isCompleted = goal.isCompleted ?? false
    }
    
    var body: some View {
        VStack {
            Section(header: Text("Goal Details").font(.headline)) {
                Text(goal.name)
                    .font(.subheadline)
                Text(goal.description)
                    .font(.caption)
                Text(goal.startDate.formatted(date: .abbreviated, time: .shortened))
                Text(goal.endDate.formatted(date: .abbreviated, time: .shortened))
                Text(goal.isActive ?? false ? "Active" : "Inactive")
            }
            .padding(.bottom)
            
            Spacer()
            
            VStack {
                Text("Edit this goal")
                    .foregroundStyle(Color.red)
                HStack {
                    Text("Name")
                    TextField("Name", text: $name)
                }
                HStack {
                    Text("Description")
                    TextField("Description", text: $description)
                }
                HStack {
                    Text("Start Date")
                    DatePicker("Select Start Time", selection: $startDate.animation(.default), displayedComponents: .hourAndMinute)
                }
                
                HStack {
                    Text("End Date")
                    DatePicker("Select End Time", selection: $endDate.animation(.default), displayedComponents: .hourAndMinute)
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
                goals.removeGoalAtId(uuid: self.goal.id)
                logger.info("Deleting goal with id \(self.goal.id)")
                goals.addGoal(goal: Goal(id: self.goal.id, name: name, description: description, startDate: startDate, endDate: endDate, isActive: isActive, isCompleted: isCompleted))
            })
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(style: StrokeStyle(lineWidth: 2)))
            
        }
        .environment(goals)
    }
}

#Preview {
    let goal = Goal(id: UUID(), name: "A Water TestGoal", description: "First", startDate: Date(), endDate: Date().addingTimeInterval(60*60*2), isActive: true)
    GoalFullView(goal: goal)
        .environment(Goals())
}
