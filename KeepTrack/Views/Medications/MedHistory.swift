//
//  MedHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/23/25.
//

import SwiftUI
import OSLog

struct MedHistory: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "MedHistory")
    @Environment(MedicationStore.self) var medicationStore
    
    private func getToday() -> [MedicationEntry] {
        let todays = medicationStore.medicationHistory.filter { Calendar.current.isDateInToday($0.date) }
        return  todays
    }
    
    private func getYesterday() -> [MedicationEntry] {
        let yesterdays = medicationStore.medicationHistory.filter { Calendar.current.isDateInYesterday($0.date) }
        return  yesterdays
    }
    var body: some View {
        VStack {
            Text("Meds")
                .font(.headline)
        

            List {
                Section(header: Text("Today")) {
                    ForEach(getToday(), id: \.self.date) { entry in
                        Text(entry.date, style: .time)
                    }
                    Text("Total " + getToday().count.description)
                }
                
                Section(header: Text("Yesterday")) {
                    Text("Total " + getYesterday().count.description)
                }
            }
        }
        .environment(medicationStore)
    }
}

#Preview {
    MedHistory()
        .environment(MedicationStore())
}
