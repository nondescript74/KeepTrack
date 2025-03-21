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
    
    let columnLayout = Array(repeating: GridItem(.flexible()), count: 5)
    
    var body: some View {
        NavigationStack {
            LazyVGrid(columns: columnLayout) {
                VStack {
                    NavigationLink(destination: WaterHistory()) {
                        Image(systemName: "fork.knife.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 70)
                    }
                    .padding(.horizontal)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2).frame(width:50, height:50))
                    .padding(.horizontal)
                    Text("History")
                }
                VStack {
                    NavigationLink(destination: EnterWater()) {
                        Image(systemName: "magnifyingglass")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 70)
                    }
                    .padding(.horizontal)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2).frame(width:50, height:50))
                    .padding(.horizontal)
                    Text("Enter")
                }
                VStack {
                    NavigationLink(destination: EditWaterHistory(items: $water.waterHistory)) {
                        Image(systemName: "heart.text.clipboard")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 70)
                    }
                    .padding(.horizontal)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2).frame(width:50, height:50))
                    .padding(.horizontal)
                    Text("Edit")
                }
            }
        }
        .environment(water)
    }
}

#Preview {
    AppDashboard()
        .environment(Water())
}
