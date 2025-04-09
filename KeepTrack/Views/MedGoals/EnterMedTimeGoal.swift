//
//  EnterMedTimeGoal.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/30/25.
//

import SwiftUI
import OSLog

struct EnterMedTimeGoal: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterMedTimeGoal")
    @Environment(MedGoals.self) var medGoals
    @Environment(\.dismiss) var dismiss
    @State private var selectedStartTime:Date = Date()
    @State private var selectedSecondStartTime: Date = Date()
    @State private var selectedThirdStartTime: Date = Date()
    @State private var medicationName: String = ""
    @State private var selectedFrequency: String = "Once daily"
    
    fileprivate let types = ["Rosuvastatin", "Metformin", "Losartan", "Latanoprost", "Other"]
    
    fileprivate let frequencies: [String] = ["Once daily", "Twice daily", "Three times daily"]
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("Enter Medication Goal").font(.headline)
            Picker("Select Type", selection: $medicationName) {
                ForEach(types, id: \.self) {
                    Text($0)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
            if selectedFrequency == "Once daily" {
                DatePicker("Start Time", selection: $selectedStartTime.animation(.default), displayedComponents: .hourAndMinute)
            } else if selectedFrequency == "Twice daily" {
                VStack(alignment: .leading) {
                    DatePicker("Start Time 1", selection: $selectedStartTime.animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 2", selection: $selectedSecondStartTime.animation(.default), displayedComponents: .hourAndMinute)
                }
            } else if selectedFrequency == "Three times daily" {
                VStack(alignment: .leading) {
                    DatePicker("Start Time 1", selection: $selectedStartTime.animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 2", selection: $selectedSecondStartTime.animation(.default), displayedComponents: .hourAndMinute)
                    DatePicker("Start Time 3", selection: $selectedThirdStartTime.animation(.default), displayedComponents: .hourAndMinute)
                }
            }
            
            Picker("Select Frequency", selection: $selectedFrequency) {
                ForEach(frequencies, id: \.self) {
                    Text($0)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
            Button(action: ({
                if self.medicationName.isEmpty {
                    return
                }
                logger.info("second start time: \(selectedSecondStartTime)")
                logger.info("third start time: \(selectedThirdStartTime)")
                medGoals.addMedGoalWithFrequency(id: UUID(), name: self.medicationName, dosage: 1, frequency: selectedFrequency, time: selectedStartTime, startdate: selectedStartTime, enddate: selectedStartTime.addingTimeInterval(60*60), isActive: true, isCompleted: false, secondStartDate: selectedSecondStartTime, thirdStartDate: selectedThirdStartTime)
                
                self.medicationName = ""

                
            }), label: ({
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
            }))
            .disabled(medicationName.isEmpty)
        }
        Spacer()
    }
}

#Preview {
    EnterMedTimeGoal()
        .environment(MedGoals())
}
