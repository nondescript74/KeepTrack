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
    @State private var name: String = ""
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                DatePicker("Start Time", selection: $selectedStartTime.animation(.default), displayedComponents: .hourAndMinute)
                TextField("Name", text: $name)
                
                Button(action: ({
                    if self.name.isEmpty {
                        return
                    }
                    medGoals.addMedGoal(id: UUID(), name: self.name, dosage: 1, frequency: "twice daily", time: selectedStartTime, goalmet: false)
                    logger.log("Added medication goal \(dateFormatter.string(from: selectedStartTime))")
                    dismiss()
                    
                }), label: ({
                    Text("add")
                }))
            }
            .padding(.horizontal)
            Spacer()
        }
        
    }
}

#Preview {
    EnterMedTimeGoal()
        .environment(MedGoals())
}
