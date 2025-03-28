//
//  WaterConsumptionGraph.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/28/25.
//

import SwiftUI
import OSLog

struct WaterConsumptionGraph: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "WaterConsumptionGraph")
    @Environment(Water.self) private var water
    
    
    var body: some View {
        ZStack {
            Arc(startangle: .degrees(0), endangle: .degrees(60), clockwise: false, color: Color.red)
            Arc(startangle: .degrees(60), endangle: .degrees(120), clockwise: false, color: Color.green)
            Arc(startangle: .degrees(120), endangle: .degrees(180), clockwise: false, color: Color.blue)
            Arc(startangle: .degrees(180), endangle: .degrees(240), clockwise: false, color: Color.yellow)
            Arc(startangle: .degrees(240), endangle: .degrees(300), clockwise: false, color: Color.purple)
            Arc(startangle: .degrees(300), endangle: .degrees(360), clockwise: false, color: Color.orange)
        }
    }

}

#Preview {
    WaterConsumptionGraph()
        .environment(Water())
}
