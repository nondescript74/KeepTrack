//
//  GoalsDisplay.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/28/25.
//

import SwiftUI
import OSLog

struct GoalsDisplay: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "GoalsDisplay")
    @Environment(Goals.self) private var goals
    @Environment(Water.self) private var water
    fileprivate var startDegrees: Double = 270
    fileprivate var colors: [Color] = [.orange, .yellow, .blue, .indigo, .purple, .pink, .cyan]
    
    fileprivate func getViews() -> [Arc] {
        var myReturn: [Arc] = []
        for (index, _) in goals.goals.enumerated() {
            let myStartDegrees: Double = startDegrees + 360 / Double(goals.goals.count) * Double(index)
            let endDegrees: Double = myStartDegrees + 360 / Double(goals.goals.count)
            myReturn.append(Arc(startangle: .degrees(myStartDegrees), endangle: .degrees(endDegrees), clockwise: false, color: colors[index], size: 50))
             
        }
        return myReturn
    }
    
    fileprivate func getWaterEntries() -> [Arc] {
        var myReturn: [Arc] = []
        if getWaterToday().isEmpty { return myReturn }
        for (index, waterentry) in getWaterToday().enumerated() {
            let myStartDegrees: Double = startDegrees + 360 / Double(goals.goals.count) * Double(index)
            let endDegrees: Double = myStartDegrees + 360 / Double(goals.goals.count)
            let met = waterentry.goalMet ?? false
            myReturn.append(Arc(startangle: .degrees(myStartDegrees), endangle: .degrees(endDegrees), clockwise: false, color: met ? .green : .red, size: met ? 80 : 66))
             
        }
        return myReturn
    }
    
    fileprivate func getWaterToday() -> [WaterEntry] {
        let todays = water.waterHistory.filter { Calendar.current.isDateInToday($0.date) }
            .filter { $0.units > 0 }
        return  todays
    }
    
    var body: some View {
        VStack {
            if goals.goals.isEmpty {
                Text("No goals set yet.")
            } else {
                VStack {
                    ZStack {
                        ForEach(getViews(), id: \.self.color) { arc in
                            arc
                        }
                        ForEach(getWaterEntries(), id: \.self.startangle) { arc in
                            arc
                        }
                        Text("\(goals.goals.count) goals")
                            .font(.caption)
                        
                    }
                }
            }
        }
        .padding(10)
        .background((Color.gray.opacity(0.1)))
        .environment(goals)
        .environment(water)
    }
}

#Preview {
    GoalsDisplay()
        .environment(Goals())
        .environment(Water())
}
