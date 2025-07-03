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
    @Environment(CurrentIntakeTypes.self) var cIntakeTypes
    
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
                            .font(.largeTitle)
                    }
                }
            }
            .navigationTitle(Text("Edit Goals"))
        }
        .environment(goals)
        .environment(cIntakeTypes)
        #if os(VisionOS)
        .glassBackgroundEffect()
        #endif
    }
    
}

#Preview {
    @Previewable @State var items: [CommonGoal] =
    [CommonGoal(id: UUID(), name: "Losartan", description: "Blood pressure", dates: [Date()], isActive: true, isCompleted: false, dosage: 25.0, units: "mg", frequency: "once daily"),
     CommonGoal(id: UUID(), name: "Metformin", description: "Sugar control", dates: [Date(), Date().addingTimeInterval(60 * 60 * 2)], isActive: true, isCompleted: false, dosage: 400, units: "mgs", frequency: "twice a day")]
    
    EditGoals(items: $items)
        .environment(CommonGoals())
        .environment(CurrentIntakeTypes())
}

