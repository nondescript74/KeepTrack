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
    
    let rowLayout = Array(repeating: GridItem(.flexible(minimum: 10)), count: 3)
    
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
                            if getToday().isEmpty {
                                Text("No water")
                                    .foregroundColor(.gray)
                            } else {
                                LazyHGrid(rows: rowLayout) {
                                    ForEach(getToday(), id: \.self.date) { entry in
                                        Text(entry.date, style: .time)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .padding(.leading)
                        Spacer()
                        GoalsDisplay()

                    }
                    .background(Color.green.opacity(0.1))
                    Text("Drank " + getToday().count.description + " - 14 oz glasses")
                        .foregroundStyle(water.waterHistory.count >= goals.goals.count ? Color.green : Color.red)
                }
                
                Section(header: Text("Yesterday")) {
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
