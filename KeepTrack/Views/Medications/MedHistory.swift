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
    @Environment(MedicationStore.self) private var medicationStore
    @Environment(MedGoals.self) private var medGoals
    
    let rowLayout = Array(repeating: GridItem(.flexible(minimum: 10)), count: 3)

    
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
                    HStack {

                        VStack(alignment: .leading) {
                            if getToday().isEmpty {
                                Text("No meds taken")
                                    .foregroundColor(.gray)
                            } else {
                                LazyHGrid(rows: rowLayout) {
                                    ForEach(getToday(), id: \.self.date) { entry in
                                        HStack {
                                            Text(entry.date, style: .time)
                                            Text(entry.name ?? "no name")
                                        }
                                        .font(.caption)
                                    }
                                }
                            }
                        }
                        Spacer()
                        MedsDisplay()

                    }
                    .background(Color.green.opacity(0.1))
                    Text("Took " + getToday().count.description + " - medications")
                        .foregroundStyle(medicationStore.medicationHistory.count >= medGoals.medGoals.count ? Color.green : Color.red)
                }
                
                Section(header: Text("Yesterday")) {
                    Text("Total " + getYesterday().count.description)
                }
            }
        }
        .environment(medicationStore)
        .environment(medGoals)
    }
}

#Preview {
    MedHistory()
        .environment(MedicationStore())
        .environment(MedGoals())
}
