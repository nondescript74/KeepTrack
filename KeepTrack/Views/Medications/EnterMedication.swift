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
    @Environment(\.dismiss) var dismiss
    @State var medicationName: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Enter medication")
                
                TextField("Medication name", text: $medicationName)
                
                Button("Add") {
                    medicationStore.addMedicationWithNameAndGoalmet(name: medicationName, goalmet: false)
                    dismiss()
                }
                
            }
            .padding(.horizontal)
            .environment(medicationStore)
            Spacer()
        }
    }
}

#Preview {
    EnterMedication()
        .environment(MedicationStore())
}
