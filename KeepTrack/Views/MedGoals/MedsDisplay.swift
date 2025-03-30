//
//  MedsDisplay.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/29/25.
//

import SwiftUI
import OSLog

struct MedsDisplay: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "MedsDisplay")
    @Environment(MedGoals.self) private var medGoals
    @Environment(MedicationStore.self) private var medicationStore
    fileprivate var startDegrees: Double = 270
    fileprivate var colors: [Color] = [.orange, .yellow, .blue, .indigo, .purple, .pink, .cyan]
    
    fileprivate func getViews() -> [Arc] {
        var myReturn: [Arc] = []
        for (index, _) in medGoals.medGoals.enumerated() {
            let myStartDegrees: Double = startDegrees + 360 / Double(medGoals.medGoals.count) * Double(index)
            let endDegrees: Double = myStartDegrees + 360 / Double(medGoals.medGoals.count)
            myReturn.append(Arc(startangle: .degrees(myStartDegrees), endangle: .degrees(endDegrees), clockwise: false, color: colors[index], size: 50))
             
        }
        return myReturn
    }
    
    fileprivate func getMedEntries() -> [Arc] {
        var myReturn: [Arc] = []
        if getMedsToday().isEmpty { return myReturn }
        for (index, medicationentry) in getMedsToday().enumerated() {
            let myStartDegrees: Double = startDegrees + 360 / Double(medGoals.medGoals.count) * Double(index)
            let endDegrees: Double = myStartDegrees + 360 / Double(medGoals.medGoals.count)
            let met = medicationentry.goalMet ?? false
            myReturn.append(Arc(startangle: .degrees(myStartDegrees), endangle: .degrees(endDegrees), clockwise: false, color: met ? .green : .red, size: met ? 80 : 66))
             
        }
        return myReturn
    }
    
    fileprivate func getMedsToday() -> [MedicationEntry] {
        let todays = medicationStore.medicationHistory.filter { Calendar.current.isDateInToday($0.date) }
        return  todays
    }
    
    var body: some View {
        VStack {
            if medGoals.medGoals.isEmpty {
                Text("No goals set yet.")
            } else {
                VStack {
                    ZStack {
                        ForEach(getViews(), id: \.self.color) { arc in
                            arc
                        }
                        ForEach(getMedEntries(), id: \.self.startangle) { arc in
                            arc
                        }
                        Text("\(medGoals.medGoals.count) goals")
                            .font(.caption)
                        
                    }
                }
            }
        }
        .padding(10)
        .background((Color.gray.opacity(0.1)))
        .environment(medGoals)
        .environment(medicationStore)
    }
}

#Preview {
    MedsDisplay()
        .environment(MedGoals())
        .environment(MedicationStore())
}
