//
//  WaterHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/19/25.
//

import SwiftUI
import OSLog

struct WaterHistory: View {
    @Environment(Water.self) fileprivate var water
    var body: some View {
        Text("Water history")
        List {
            ForEach(water.waterHistory, id: \.self.date) { entry in
                Text(entry.date, style: .date)
            }

        }
    }
}

#Preview {
    WaterHistory()
        .environment(Water())
}
