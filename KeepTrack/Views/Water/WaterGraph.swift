//
//  WaterGraph.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/27/25.
//

import SwiftUI
import OSLog

struct WaterGraph: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditWaterHistory")
    
    @Environment(Water.self) var water
    @Environment(Goals.self) var goals
    var body: some View {
         VStack {
             Text(goals.goals.count.description)
        }
    }
}

#Preview {
    WaterGraph()
        .environment(Water())
    
}
