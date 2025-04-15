//
//  CommonDisplay.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog

struct CommonDisplay: View {
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CommonDisplay")
    @Environment(CommonGoals.self) private var goals
    @Environment(CommonStore.self) private var store
    
    fileprivate var startDegrees: Double = 270
    fileprivate var colors: [Color] = [.orange, .yellow, .blue, .indigo, .purple, .pink, .cyan]
    
    fileprivate func getViews() -> [Arc] {
        var myReturn: [Arc] = []
        for (index, _) in goals.goals.filter({$0.isActive}).enumerated() {
            let myStartDegrees: Double = startDegrees + 360 / Double(goals.goals.filter({$0.isActive}).count) * Double(index)
            let endDegrees: Double = myStartDegrees + 360 / Double(goals.goals.filter({$0.isActive}).count)
            myReturn.append(Arc(startangle: .degrees(myStartDegrees), endangle: .degrees(endDegrees), clockwise: false, color: colors[index], size: 50))
        }
        return myReturn
    }
    
    fileprivate func getEntries() -> [Arc] {
        var myReturn: [Arc] = []
        if getToday().isEmpty { return myReturn }
        for (index, entry) in getToday().enumerated() {
            let myStartDegrees: Double = startDegrees + 360 / Double(goals.goals.filter({$0.isActive}).count) * Double(index)
            let endDegrees: Double = myStartDegrees + 360 / Double(goals.goals.filter({$0.isActive}).count)
            let met = entry.goalMet
            myReturn.append(Arc(startangle: .degrees(myStartDegrees), endangle: .degrees(endDegrees), clockwise: false, color: met ? .green : .red, size: met ? 80 : 66))
        }
        return myReturn
    }
    
    fileprivate func getToday() -> [CommonEntry] {
        let todays = store.history.filter { Calendar.current.isDateInToday($0.date) }
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
                        ForEach(getEntries(), id: \.self.startangle) { arc in
                            arc
                        }
                        Text("\(goals.goals.filter({$0.isActive}).count) goals")
                            .font(.caption)
                        
                    }
                }
            }
        }
        .padding(10)
        .background((Color.gray.opacity(0.1)))
        .environment(goals)
        .environment(store)
    }
}

#Preview {
    CommonDisplay()
        .environment(CommonGoals())
        .environment(CommonStore())
}

