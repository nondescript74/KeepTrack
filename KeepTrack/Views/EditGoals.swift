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
    
    var body: some View {
        NavigationView {
            VStack {
                MovableGoalList(self.$items) { item in
                    Text("\(item.name.wrappedValue)")
                }
            }
//            .navigationTitle(Text("Edit Goals"))
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
    [CommonGoal(id: UUID(), name: "Losartan", description: "Blood pressure", dates: [Date()], isActive: true, isCompleted: false, dosage: 25.0, units: "mg", frequency: frequency.daily.rawValue),
     CommonGoal(id: UUID(), name: "Metformin", description: "Sugar control", dates: [Date(), Date().addingTimeInterval(60 * 60 * 2)], isActive: true, isCompleted: false, dosage: 400, units: "mgs", frequency: frequency.twiceADay.rawValue)]
    
    EditGoals(items: $items)
        .environment(CommonGoals())
        .environment(CurrentIntakeTypes())
}

