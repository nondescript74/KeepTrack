//
//  GoalDisplayByName.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/22/25.
//

import SwiftUI
import OSLog

struct GoalDisplayByName: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "GoalDisplayByName")
    @Environment(CommonGoals.self) private var goals
    @EnvironmentObject private var cIntakeTypes: CurrentIntakeTypes
    
    fileprivate var startDegrees: Double = 270
    fileprivate var myGoals:[CommonGoal] {
        return goals.goals.sorted { $0.name < $1.name }
    }
    
    fileprivate func isItAM(_ date: Date) -> Bool {
        return hourForDate(date) >= 0 && hourForDate(date) < 12
    }
    
    var body: some View {
        VStack {
            Text("Intake Goals For the Day")
                .font(.title)
                .foregroundColor(.secondary)
            
            if myGoals.isEmpty {
                Text("No goals yet!")
                    .foregroundColor(.secondary)
                    .font(.headline)
            } else {
                VStack {
                    ScrollView {
                        ForEach(myGoals.sorted(by: {$0.name < $1.name}).indices, id: \.self) { index in
                            let goal = myGoals[index]
                            HStack(alignment: .center) {
                                Text(goal.name)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal) {
                                    HStack(alignment: .center) {
                                        ForEach(goal.dates, id: \.self) { date in
                                            HStack {
                                                Clock(hour: hourForDate(date), minute: minuteForDate(date), is12HourFormat: true, isAM: self.isItAM(date), colorGreen: false)
                                            }
                                            .padding(.all, 10)
                                        }
                                    }
                                }
                            }
                            .font(.caption)
                        }
                    }
                }
                Spacer()
                Divider()
            }
        }
        .environment(goals)
    }
}

#Preview {
    GoalDisplayByName()
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
