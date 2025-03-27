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
    @State private var selectedStartTime:Date = Date()
    @State private var selectedEndTime:Date = Date()
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        HStack {
            DatePicker("Select Start Time", selection: $selectedStartTime.animation(.default), displayedComponents: .hourAndMinute)
            DatePicker("Select End Time", selection: $selectedEndTime.animation(.default), displayedComponents: .hourAndMinute)
        }
        .padding()
        HStack {
            Text("Time between \(dateFormatter.string(from: selectedStartTime)) to \(dateFormatter.string(from: selectedEndTime))")
            Button(action: ({
                goals.addGoal(id: UUID(), name: "Early", description: "First goal", startDate: selectedStartTime, endDate: selectedEndTime)
                logger.log("Calculating time between \(dateFormatter.string(from: selectedStartTime)) to \(dateFormatter.string(from: selectedEndTime))")
                
            }), label: ({
                Text("add")
            }))
        }
        
    }
}

#Preview {
    EnterWaterTimeGoal()
}
