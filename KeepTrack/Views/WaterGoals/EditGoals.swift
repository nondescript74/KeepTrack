//
//  EditGoals.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/26/25.
//

import SwiftUI
import OSLog

struct EditGoals: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditGoals")
    @Environment(Goals.self) var goals
    @Binding var items: [Goal]
    
    var body: some View {
        NavigationView {
            VStack {
                EditableGoalsList($items) { item in
                    Text("\(item.startDate.wrappedValue.formatted(date: .abbreviated, time: .standard))")
                }
            }
            .navigationTitle(Text("Edit Goals"))
        }
        .environment(goals)
    }
        
}

#Preview {
    @Previewable @State var items: [Goal] = [Goal(id: UUID(), name: "First Goal", description: "A water goal", startDate: Date(), endDate: Date().addingTimeInterval(60*60*2)), Goal(id: UUID(), name: "Second Goal", description: "Another water goal", startDate: Date().addingTimeInterval(60*60*2 + 1), endDate: Date().addingTimeInterval(60*60*4))]
    EditGoals(items: $items)
        .environment(Goals())
}
