//
//  WaterHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/19/25.
//

import SwiftUI
import OSLog

struct WaterHistory: View {
    @Environment(Water.self) var water
    @Environment(Goals.self) var goals
    
    private func getToday() -> [WaterEntry] {
        let todays = water.waterHistory.filter { Calendar.current.isDateInToday($0.date) }
            .filter { $0.units > 0 }
        return  todays
    }
    
    private func getYesterday() -> [WaterEntry] {
        let yesterdays = water.waterHistory.filter { Calendar.current.isDateInYesterday($0.date) }
            .filter { $0.units > 0 }
        return  yesterdays
    }
    
    var body: some View {
        VStack {
            Text("Water")
                .font(.headline)
            List {
                Section(header: Text("Today")) {
                    HStack {
                        VStack(alignment: .leading) {
                            ForEach(getToday(), id: \.self.date) { entry in
                                Text(entry.date, style: .time)
                            }
                        }
                        Spacer()
                        GoalsDisplay()
                    }
                    .background(Color.green.opacity(0.1))
                    Text("Drank " + getToday().count.description + " - 14 oz glasses")
                }
                
                Section(header: Text("Yesterday")) {
//                    ForEach(getYesterday(), id: \.self.date) { entry in
//                        Text(entry.date, style: .time)
//                    }
                    
                    Text("Drank " + getYesterday().count.description + " - 14 oz glasses")
                }
            }
        }
        .environment(water)
        .environment(goals)
    }
}

#Preview {
    WaterHistory()
        .environment(Water())
        .environment(Goals())
}
