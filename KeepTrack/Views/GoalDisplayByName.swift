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
        
        VStack(spacing: 18) {
            Text("Intake Goals")
                .font(.largeTitle).bold()
                .foregroundStyle(Color.blue)
                .shadow(color: .blue.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding(.top, 10)
            
            if myGoals.isEmpty {
                Text("No goals yet!")
                    .foregroundColor(.secondary)
                    .font(.headline)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(myGoals) { goal in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(goal.name)
                                        .font(.headline)
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text(goal.isActive ? "Active" : "Inactive")
                                        .font(.caption)
                                        .foregroundColor(goal.isActive ? .green : .secondary)
                                }
                                HStack(alignment: .center, spacing: 4) {
                                    Text("Times:")
                                        .font(.caption)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 6) {
                                            ForEach(goal.dates, id: \.self) { date in
                                                DigitalClockView(hour: hourForDate(date), minute: minuteForDate(date), is12HourFormat: true, isAM: self.isItAM(date), colorGreen: false)
                                                    .padding(6)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16).stroke(Color.accentColor.opacity(0.18), lineWidth: 1.2)
                            )
                            .shadow(color: .black.opacity(0.04), radius: 1, y: 1)
                            .padding(.horizontal, 6)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 4)
            }
            Spacer(minLength: 28)
        }
        .environment(goals)
    }
}

#Preview {
    GoalDisplayByName()
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
