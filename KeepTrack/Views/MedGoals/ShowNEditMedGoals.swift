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
                                .font(.subheadline)
                                
                            Text(item.startDate.wrappedValue?.formatted(date: .omitted, time: .shortened) ?? item.time.wrappedValue.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                
                            Text(item.frequency.wrappedValue)
                                .font(.caption)
                                
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
        MedicationGoal(name: "Losartan", dosage: 25, frequency: "Once daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false),
        MedicationGoal(name: "Metformin", dosage: 1, frequency: "Twice daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false, secondStartDate: Date().addingTimeInterval(60 * 60 * 12)),
        MedicationGoal(name: "Latanoprost Goal", dosage: 1, frequency: "Three times daily", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), isActive: true, isCompleted: false, secondStartDate: Date().addingTimeInterval(60 * 60 * 6), thirdStartDate: Date().addingTimeInterval(60 * 60 * 12))
        
    ]
    ShowNEditMedGoals(items: $items)
        .environment(MedGoals())
}
