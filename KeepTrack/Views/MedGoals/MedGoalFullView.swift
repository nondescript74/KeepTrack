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
    @State private var secondStartDate: Date
    @State private var thirdStartDate: Date
    
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
        self.secondStartDate = medgoal.secondStartDate ?? Date()
        self.thirdStartDate = medgoal.thirdStartDate ?? Date()
    }
    
    var body: some View {
        VStack {
            Section(header: Text("Goal Details").font(.headline)) {
                Text(medgoal.name)
                    .font(.subheadline)
                Text(medgoal.dosage.description)
                    .font(.caption)
                
                
                Text(medgoal.isActive ?? false ? "Active" : "Inactive")
                Text(medgoal.isCompleted ?? false ? "Completed" : "Incomplete")
                Text((frequency.lowercased().contains("twice") ? "Take twice a day" : frequency.lowercased().contains("three") ? "Take three times a day" : "Take once a day"))
                HStack {
                    Text((medgoal.startDate != nil) ? startDate.formatted(date: .omitted, time: .shortened) : "No start?")
                    Text((medgoal.secondStartDate != nil) ? secondStartDate.formatted(date: .omitted, time: .shortened) : "")
                    Text((medgoal.thirdStartDate != nil) ? thirdStartDate.formatted(date: .omitted, time: .shortened) : "")
                }
            }
            .padding(.bottom)
            
            Spacer()
            
            VStack {
                Text("Edit this Medication Goal")
                    .font(.title)
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
                    DatePicker("Select Start time", selection: $startDate.animation(.default), displayedComponents: .hourAndMinute)
                }
                
                HStack {
                    DatePicker("Select End date", selection: $endDate.animation(.default), displayedComponents: .date)
                }
                
                if frequency.lowercased().contains("twice") || frequency.lowercased().contains("three") {
                    HStack {
                        DatePicker("Second Start", selection: $secondStartDate.animation(.default), displayedComponents: .hourAndMinute)
                    }
        
                }
                
                if frequency.lowercased().contains("three") {
                    HStack {
                        DatePicker("Third start", selection: $thirdStartDate.animation(.default), displayedComponents: .hourAndMinute)
                    }
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
                logger.info("Deleting medgoal with id \(self.medgoal.id)")
                medgoals.removeMedGoalAtId(uuid: self.medgoal.id)
                logger.info("Adding new medgoal with id \(self.medgoal.id)")
                medgoals.addMedGoalWithFrequency(id: self.medgoal.id, name: self.name, dosage: self.dosage, frequency: self.frequency, time: self.time, startdate: self.startDate, enddate: self.endDate, isActive: self.isActive, isCompleted: self.isCompleted, secondStartDate: self.secondStartDate, thirdStartDate: self.thirdStartDate)
                dismiss()
            })
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(style: StrokeStyle(lineWidth: 2)))
            
        }
        .environment(medgoals)
    }

}

#Preview {
    
    let medGoalA = MedicationGoal(name: "Metformin Goal", dosage: 500, frequency: "Twice daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false, secondStartDate: Date().addingTimeInterval(60 * 60 * 10))
    let medGoalB = MedicationGoal(name: "Acetomenophen Goal", dosage: 500, frequency: "three times daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false, secondStartDate: Date().addingTimeInterval(60 * 60 * 6), thirdStartDate: Date().addingTimeInterval(60 * 60 * 12))
    MedGoalFullView(medgoal: medGoalB)
        .environment(MedGoals())
}
