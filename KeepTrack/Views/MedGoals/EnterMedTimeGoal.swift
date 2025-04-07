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
    @State private var medicationName: String = ""
    
    fileprivate let types = ["Rosuvastatin", "Metformin", "Losartan", "Latanoprost", "Other"]
    
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
            
            DatePicker("Start Time", selection: $selectedStartTime.animation(.default), displayedComponents: .hourAndMinute)
            
            Button(action: ({
                if self.medicationName.isEmpty {
                    return
                }
                medGoals.addMedGoal(id: UUID(), name: self.medicationName, dosage: 1, frequency: "twice daily", time: selectedStartTime, goalmet: false)
                logger.log("Added medication goal \(dateFormatter.string(from: selectedStartTime))")
                dismiss()
                
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
