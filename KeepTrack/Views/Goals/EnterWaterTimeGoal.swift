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
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                DatePicker("Select Start Time", selection: $selectedStartTime.animation(.default), displayedComponents: .hourAndMinute)
                DatePicker("Select End Time", selection: $selectedEndTime.animation(.default), displayedComponents: .hourAndMinute)
            }
            .padding()
            HStack {
                Text("Time between \(dateFormatter.string(from: selectedStartTime)) to \(dateFormatter.string(from: selectedEndTime))")
                Button(action: ({
                    goals.addGoal(id: UUID(), name: "Early", description: "First goal", startDate: selectedStartTime, endDate: selectedEndTime, isActive: true)
                    logger.log("Calculating time between \(dateFormatter.string(from: selectedStartTime)) to \(dateFormatter.string(from: selectedEndTime))")
                    dismiss()
                    
                }), label: ({
                    Text("add")
                }))
            }
            Spacer()
        }
    }
}

#Preview {
    EnterWaterTimeGoal()
        .environment(Goals())
}
