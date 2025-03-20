//
//  AppDashboard.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/19/25.
//

import Foundation
import SwiftUI
import OSLog

struct AppDashboard: View {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "AppDashboard")
    @State private var water = Water()
    
    //    let columnLayout = Array(repeating: GridItem(.flexible()), count: 5)
    var body: some View {
        NavigationStack {
            ScrollView {
                WaterHistory()
                EnterWater()
            }
            .environment(water)
        }
        
    }
}

#Preview {
    AppDashboard()
        .environment(Water())
}
