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
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("Intake Goals")
                .font(.largeTitle)
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
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal) {
                            HStack(alignment: .center) {
                                ForEach(goal.dates, id: \.self) { date in
                                    HStack {
                                        Calendar.autoupdatingCurrent.dateComponents([.hour], from: date).hour.map {
                                            Text("\($0):").font(.headline) } ?? Text("")
                                        Calendar.autoupdatingCurrent.dateComponents([.minute], from: date).minute.map { Text("\($0)").font(.headline) } ?? Text("")
                                    }
                                    .padding([.leading, .trailing], 5)
                                    .font(.footnote)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))
                                    .background(content: {
                                        Color.gray.opacity(0.2)
                                    })
                                }
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
