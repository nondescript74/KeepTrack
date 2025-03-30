//
//  EditMedGoals.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/30/25.
//

import SwiftUI
import OSLog

struct EditMedGoals: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditMedGoals")
    @Environment(MedGoals.self) var medGoals
    @Binding var items: [MedicationGoal]
    
    var body: some View {
        NavigationView {
            VStack {
                EditableMedGoalsList($items) { item in
                    Text("\(item.time.wrappedValue.formatted(date: .abbreviated, time: .standard))")
                }
            }
            .navigationTitle(Text("Edit Medication Goals"))
        }
        .environment(medGoals)
    }
        
}

#Preview {
    @Previewable @State var items: [MedicationGoal] = [
        MedicationGoal(name: "morning", frequency: "once"),
        MedicationGoal(name: "midday", frequency: "once"),
        MedicationGoal(name: "evening", frequency: "once")
        
    ]
    EditMedGoals(items: $items)
        .environment(MedGoals())
}
