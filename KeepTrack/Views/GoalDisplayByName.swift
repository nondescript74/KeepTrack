//
//  GoalDisplayByName.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/22/25.
//

import SwiftUI
import OSLog

struct GoalDisplayByName: View {
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "GoalDisplayByName")
    @Environment(CommonGoals.self) private var goals
    
    fileprivate var startDegrees: Double = 270
    fileprivate var colors: [Color] = [.orange, .yellow, .blue, .indigo, .purple, .pink, .cyan]
    fileprivate var myGoals:[CommonGoal] {
        return goals.goals.sorted { $0.name < $1.name }
    }
    
    fileprivate func hourForDate(_ date: Date) -> Int {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = .current
        let components = calendar.dateComponents([.hour], from: date)
        return components.hour ?? 0
    }
    
    fileprivate func minuteForDate(_ date: Date) -> Int {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = .current
        let components = calendar.dateComponents([.minute], from: date)
        return components.minute ?? 0
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
                ForEach(myGoals.indices, id: \.self) { index in
                    let goal = myGoals[index]
                    HStack(alignment: .center) {
                        Text(goal.name)
                            .foregroundColor(colors[index % colors.count])
                            .font(.subheadline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal) {
                            HStack(alignment: .center) {
                                ForEach(goal.dates, id: \.self) { date in
                                    HStack {
                                        Clock(hour: hourForDate(date), minute: minuteForDate(date), is12HourFormat: true, isAM: isItAM(date))
                                        
                                    }
                                    .font(.footnote)
//                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
            }
        }
        .environment(goals)
    }
}

#Preview {
    GoalDisplayByName()
        .environment(CommonGoals())
}
