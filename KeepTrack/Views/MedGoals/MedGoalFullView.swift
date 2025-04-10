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
                Text((frequency.lowercased().contains("twice".lowercased()) ? "Take twice a day" : frequency.lowercased().contains("three".lowercased()) ? "Take three times a day" : "Take once a day"))
                
                HStack {
                    Text((startDate.formatted(date: .omitted, time: .shortened)))
                        .foregroundStyle(Color.red)
                    
                    Text(secondStartDate.formatted(date: .omitted, time: .shortened))
                        .foregroundStyle(
                            !frequency.lowercased().contains("twice") ? Color.gray.opacity(0.01) : Color.red)
                    
                    Text(secondStartDate.formatted(date: .omitted, time: .shortened))
                        .foregroundStyle(!frequency.lowercased().contains("three") ? Color.gray.opacity(0.01) : Color.red)
                    
                    Text(thirdStartDate.formatted(date: .omitted, time: .shortened))
                        .foregroundStyle(!frequency.lowercased().contains("three") ? Color.gray.opacity(0.01) : Color.red)
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
                logger.info("name is \(self.name)")
                logger.info("dosage is \(self.dosage)")
                logger.info("frequency is \(self.frequency)")
                logger.info("startDate is \(self.startDate)")
                medgoals.addMedGoalWithFrequency(id: self.medgoal.id, name: self.name, dosage: self.dosage, frequency: self.frequency, time: self.time, startdate: self.startDate, enddate: self.endDate, isActive: self.isActive, isCompleted: self.isCompleted, secondStartDate: self.secondStartDate, thirdStartDate: self.thirdStartDate)
                logger.info("added new medgoal")
                dismiss()
            })
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(style: StrokeStyle(lineWidth: 2)))
            
        }
        .environment(medgoals)
    }

}

#Preview {
    let medGoal = MedicationGoal(name: "Rosuvastatin", dosage: 20, frequency: "Daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false)
    let medGoalA = MedicationGoal(name: "Metformin", dosage: 500, frequency: "Twice daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false, secondStartDate: Date().addingTimeInterval(60 * 60 * 10))
    let medGoalB = MedicationGoal(name: "Acetomenophen", dosage: 500, frequency: "Three times daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false, secondStartDate: Date().addingTimeInterval(60 * 60 * 6), thirdStartDate: Date().addingTimeInterval(60 * 60 * 12))
    MedGoalFullView(medgoal: medGoalB)
        .environment(MedGoals())
}
