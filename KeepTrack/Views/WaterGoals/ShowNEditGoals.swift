//
//  ShowNEditGoals.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/3/25.
//

import SwiftUI
import OSLog

struct ShowNEditGoals: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ShowNEditGoals")
    @Binding var items: [Goal]
    @Environment(Goals.self) var goals
    fileprivate func moveitems(from source: IndexSet, to destination: Int) {
        goals.goals.move(fromOffsets: source, toOffset: destination)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                MovableGoalsList($items) { item in
                    NavigationLink {
                        GoalFullView(goal: item.wrappedValue)
                    } label: {
                        Text("\(item.startDate.wrappedValue.formatted(date: .abbreviated, time: .standard))")
                    }
                }
            }
            .navigationTitle(Text("Edit Goals"))
        }
        .environment(goals)
    }
    
}

#Preview {
    @Previewable @State var items: [Goal] = [Goal(id: UUID(), name: "First Goal", description: "A water goal", startDate: Date(), endDate: Date().addingTimeInterval(60*60*2)), Goal(id: UUID(), name: "Second Goal", description: "Another water goal", startDate: Date().addingTimeInterval(60*60*2 + 1), endDate: Date().addingTimeInterval(60*60*4))]
    ShowNEditGoals(items: $items)
        .environment(Goals())
}
