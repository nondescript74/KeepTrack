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
    
    private func getToday() -> [WaterEntry] {
        let todays = water.waterHistory.filter { Calendar.current.isDateInToday($0.date) }
        return  todays
    }
    
    private func getYesterday() -> [WaterEntry] {
        let yesterdays = water.waterHistory.filter { Calendar.current.isDateInYesterday($0.date) }
        return  yesterdays
    }
    
    var body: some View {
        Text("Water history")
        
        
        List {
            Section(header: Text("Today")) {
                ForEach(getToday(), id: \.self.date) { entry in
                    Text(entry.date, style: .time)
                }
            }
            
            Section(header: Text("Yesterday")) {
                ForEach(getYesterday(), id: \.self.date) { entry in
                    Text(entry.date, style: .time)
                }
            }
            

        }
    }
}

#Preview {
    WaterHistory()
        .environment(Water())
}
