//
//  EditMedHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/24/25.
//

import SwiftUI
import OSLog

struct EditMedHistory: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditMedicationHistory")
    @Environment(MedicationStore.self) var medicationStore
    @Binding var items: [MedicationEntry]
    
    
    var body: some View {
        NavigationView {
            VStack {
                EditableMedList($items) { item in
                    Text("\(item.date.wrappedValue.formatted(date: .abbreviated, time: .standard))")
                }
            }
            .navigationTitle(Text("Edit Medication History"))
        }
        .environment(medicationStore)
    }
}

#Preview {
    @Previewable @State var items: [MedicationEntry] = [MedicationEntry(id: UUID(), date: Date()), MedicationEntry(id: UUID(), date: Date())]
    EditMedHistory(items: $items)
        .environment(MedicationStore())
}
