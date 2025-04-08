//
//  MedGoalFullView.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/6/25.
//

import SwiftUI
import OSLog

struct MedGoalFullView: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "MedGoalFullView")
    @Environment(MedGoals.self) var medgoals
    @Environment(\.dismiss) var dismiss
    fileprivate var medgoal:MedicationGoal
    @State private var name: String
    @State private var dosage: Int
    @State private var frequency: String
    @State private var time: Date
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isActive: Bool
    @State private var isCompleted: Bool
    
    init(medgoal:MedicationGoal) {
        self.medgoal = medgoal
        self.name = medgoal.name
        self.dosage = medgoal.dosage
        self.frequency = medgoal.frequency
        self.time = medgoal.time
        self.startDate = medgoal.startDate ?? Date()
        self.endDate = medgoal.endDate ?? Date()
        self.isActive = medgoal.isActive ?? false
        self.isCompleted = medgoal.isCompleted ?? false
    }
    
    var body: some View {
        VStack {
            Section(header: Text("Goal Details").font(.headline)) {
                Text(medgoal.name)
                    .font(.subheadline)
                Text(medgoal.dosage.description)
                    .font(.caption)
                Text(medgoal.frequency)
                    .font(.caption)
                Text(medgoal.time.formatted(date: .abbreviated, time: .shortened))
                Text((medgoal.startDate != nil) ? startDate.formatted(date: .abbreviated, time: .shortened) : "")
                Text(medgoal.endDate != nil ? endDate.formatted(date: .abbreviated, time: .shortened) : "")
                Text(medgoal.isActive ?? false ? "Active" : "Inactive")
                Text(medgoal.isCompleted ?? false ? "Completed" : "Incomplete")
            }
            .padding(.bottom)
            
            Spacer()
            
            VStack {
                Text("Edit this medgoal")
                    .foregroundStyle(Color.red)
                HStack {
                    Text("Name")
                    TextField("Name", text: $name)
                }
                HStack {
                    Text("Dosage")
                    TextField("Dosage", value: $dosage, format: .number)
                }
                HStack {
                    Text("Start Date")
                    DatePicker("Select Start", selection: $startDate.animation(.default), displayedComponents: .hourAndMinute)
                }
//                HStack {
//                    Text("Time")
//                    DatePicker("Select Time", selection: $time.animation(.default), displayedComponents: .hourAndMinute)
//                }
                
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
                medgoals.removeMedGoalAtId(uuid: self.medgoal.id)
                logger.info("Deleting medgoal with id \(self.medgoal.id)")
                medgoals.addMedGoalWithDates(id: self.medgoal.id, name: name, dosage: dosage, frequency: frequency, time: startDate, startdate: startDate, enddate: endDate, isActive: isActive, isCompleted: isCompleted)
                dismiss()
            })
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(style: StrokeStyle(lineWidth: 2)))
            
        }
        .environment(medgoals)
    }
    /*
     (goal: Goal(id: self.goal.id, name: name, description: description, startDate: startDate, endDate: endDate, isActive: isActive, isCompleted: isCompleted))
     */

}

#Preview {
    MedGoalFullView(medgoal: MedicationGoal(name: "Test Medication Goal", dosage: 1, frequency: "daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false))
        .environment(MedGoals())
}
