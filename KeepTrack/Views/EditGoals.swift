//
//  ShowAndEditGoals.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog

struct EditGoals: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditGoals")
    @Binding var items: [CommonGoal]
    @Environment(CommonGoals.self) var goals
    
    fileprivate func moveitems(from source: IndexSet, to destination: Int) {
        goals.goals.move(fromOffsets: source, toOffset: destination)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                MovableGoalList(self.$items) { item in
                    NavigationLink {
                        GoalFullView(goal: item.wrappedValue)
                    } label: {
                        Text("\(item.name.wrappedValue)")
                    }
                }
            }
            .navigationTitle(Text("Edit Goals"))
        }
        .environment(goals)
    }
    
}

#Preview {
    @Previewable @State var items: [CommonGoal] =
    [CommonGoal(id: UUID(), name: "Losartan", description: matchingDescriptionDictionary["Losartan"] ?? "BP Medication", dates: [Date()], isActive: true, isCompleted: false, dosage: matchingAmountDictionary["Losartan"] ?? 25.0, units: matchingUnitsDictionary["Losartan"] ?? "mg", frequency: matchingFrequencyDictionary["Losartan"] ?? "once daily"),
     CommonGoal(id: UUID(), name: "Metformin", description: matchingDescriptionDictionary["Metformin"] ?? "no description", dates: [Date(), Date().addingTimeInterval(60 * 60 * 2)], isActive: true, isCompleted: false, dosage: matchingAmountDictionary["Metformin"] ?? 0.0, units: matchingUnitsDictionary["Metformin"] ?? "fluid ounces", frequency: matchingFrequencyDictionary["Metformin"] ?? "twice a day")]
    
    EditGoals(items: $items)
        .environment(CommonGoals())
}

