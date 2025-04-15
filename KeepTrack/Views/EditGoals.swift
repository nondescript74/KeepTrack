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
                        Text("\(item.dates[0].wrappedValue.formatted(date: .abbreviated, time: .standard))")
                    }
                }
            }
            .navigationTitle(Text("Edit Goals"))
        }
        .environment(goals)
    }
    
}

#Preview {
    @Previewable @State var items: [CommonGoal] = [CommonGoal(id: UUID(), name: "Test Goal A", description: "test A", dates: [Date()]), CommonGoal(id: UUID(), name: "Test Goal B", description: "test B", dates: [Date()])]
    
    EditGoals(items: $items)
        .environment(CommonGoals())
}
