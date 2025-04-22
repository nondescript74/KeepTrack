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
    var body: some View {
        VStack {
            Text("Goals by Name")
            ForEach(goals.goals.indices, id: \.self) { index in
                let goal = goals.goals[index]
                HStack(alignment: .center) {
                    Text(goal.name)
                        .foregroundColor(colors[index % colors.count])
                        .font(.footnote)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal) {
                        HStack(alignment: .center) {
                            ForEach(goal.dates, id: \.self) { date in
                                HStack {
                                    Calendar.autoupdatingCurrent.dateComponents([.hour], from: date).hour.map { Text("\($0):") } ?? Text("")
                                    Calendar.autoupdatingCurrent.dateComponents([.minute], from: date).minute.map { Text("\($0)") } ?? Text("")
                                }
                                .padding(.trailing, 5)
                                .font(.footnote)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))
                                .background(content: {
                                    Color.orange.opacity(0.1)
                                })
                            }
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
