//
//  EnterWaterTimeGoal.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/25/25.
//

import SwiftUI
import OSLog

struct EnterWaterTimeGoal: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterWaterTimeGoal")
    @Environment(Goals.self) var goals
    @Environment(\.dismiss) var dismiss
    @State private var selectedStartTime:Date = Date()
    @State private var selectedEndTime:Date = Date()
    @State private var name: String = ""
    @State private var description: String = ""
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("Enter a liquid consumption goal")
                .font(.headline)
            TextField("Name", text: $name)
                .padding()
            TextField("Description", text: $description)
                .padding()
                
            HStack {
                DatePicker("Select Start Time", selection: $selectedStartTime.animation(.default), displayedComponents: .hourAndMinute)
                DatePicker("Select End Time", selection: $selectedEndTime.animation(.default), displayedComponents: .hourAndMinute)
            }
            .padding()
            

            
            
            Text("Time between \(dateFormatter.string(from: selectedStartTime)) to \(dateFormatter.string(from: selectedEndTime))")
            Button(action: ({
                goals.addGoal(id: UUID(), name: name, description: description, startDate: selectedStartTime, endDate: selectedEndTime, isActive: true)
                logger.log("Calculating time between \(dateFormatter.string(from: selectedStartTime)) to \(dateFormatter.string(from: selectedEndTime))")
                dismiss()
            }), label: ({
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
            }))
            .disabled(name.isEmpty || selectedEndTime < selectedStartTime || selectedEndTime == selectedStartTime)
            
            Spacer()
        }
    }
}

#Preview {
    EnterWaterTimeGoal()
        .environment(Goals())
}
