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
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.14), Color.purple.opacity(0.18), Color.white]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            .overlay(.ultraThinMaterial)

            VStack(spacing: 18) {
                Text("Intake Goals For the Day")
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
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.62), Color.purple.opacity(0.11)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                        .shadow(radius: 2, y: 1)
                        .overlay(
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(myGoals.sorted(by: {$0.name < $1.name}).indices, id: \.self) { index in
                                        let goal = myGoals[index]
                                        HStack(alignment: .center) {
                                            Text(goal.name)
                                                .padding(.horizontal)
                                            ScrollView(.horizontal, showsIndicators: false) {
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
                                .padding(.vertical, 8)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .padding(.vertical, 2)
                        )
                        .padding(.horizontal, 14)
                        .padding(.top, 2)
                }
                Spacer(minLength: 28)
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
