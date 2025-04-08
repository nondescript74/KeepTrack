//
//  ShowNEditMedGoals.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/6/25.
//

import SwiftUI
import OSLog

struct ShowNEditMedGoals: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ShowNEditMedGoals")
    @Binding var items: [MedicationGoal]
    @Environment(MedGoals.self) var medgoals
    fileprivate func moveitems(from source: IndexSet, to destination: Int) {
        medgoals.medGoals.move(fromOffsets: source, toOffset: destination)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                MovableMedGoalsList($items) { item in
                    NavigationLink {
                        MedGoalFullView(medgoal: item.wrappedValue)
                    } label: {
                        HStack {
                            Text(item.name.wrappedValue)
                                .padding(.trailing)
                            Text(item.startDate.wrappedValue?.formatted(date: .abbreviated, time: .shortened) ?? item.time.wrappedValue.formatted(date: .abbreviated, time: .shortened))
                                
//                            Text("\(String(describing: item.time.wrappedValue.formatted(date: .abbreviated, time: .shortened)))")
                        }
                    }
                }
            }
            .navigationTitle(Text("Edit MedGoals"))
        }
        .environment(medgoals)
    }
    
}

#Preview {
    @Previewable @State var items: [MedicationGoal] = [
        MedicationGoal(name: "Test Medication Goal", dosage: 1, frequency: "daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false),
        MedicationGoal(name: "Metformin Goal", dosage: 1, frequency: "twice daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false),
        MedicationGoal(name: "Latanoprost Goal", dosage: 1, frequency: "evening daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false)
        
    ]
    ShowNEditMedGoals(items: $items)
        .environment(MedGoals())
}
