//
//  EnterMedication.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/23/25.
//

import SwiftUI
import OSLog

struct EnterMedication: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterMedication")
    @Environment(MedicationStore.self) var medicationStore
    
    var body: some View {
        HStack {
            Text("Enter medication")
            
            Button("Add") {
                medicationStore.addMedication()
            }

        }
        .padding(.horizontal)
        .environment(medicationStore)
    }
}

#Preview {
    EnterMedication()
        .environment(MedicationStore())
}
