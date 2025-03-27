//
//  GoalsHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/26/25.
//

import SwiftUI
import OSLog

struct GoalsHistory: View {
    @Environment(Goals.self) var goals
    
    private func getToday() -> [Goal] {
        let todays = goals.goals.filter { Calendar.current.isDateInToday($0.startDate) }
        return  todays
    }
    
    private func getYesterday() -> [Goal] {
        let yesterdays = goals.goals.filter { Calendar.current.isDateInYesterday($0.startDate) }
        return  yesterdays
    }
    
    var body: some View {
        VStack {
            Text("Water")
                .font(.headline)
            List {
                Section(header: Text("Goals")) {
                    ForEach(goals.goals, id: \.self.startDate) { entry in
                        Text(entry.startDate, style: .time)
                    }
                    Text("Total goals today")
                }
            }
        }
        .environment(goals)
    }
}

#Preview {
    GoalsHistory()
        .environment(Goals())
}
