//
//  DisplayHKHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 5/22/25.
//

import SwiftUI
import HealthKit
import OSLog

struct DisplayHKHistory: View {
    
    @Environment(HealthKitManager.self) var healthKitManager
    @State private var showDetail = false
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "DisplayHKHistory")
    
    fileprivate var samples: [HKQuantitySample] = []
    
    var body: some View {
        VStack {
            Text(("Water Intake History"))
            
            Button(action: {
                // perform query from here
                Task {
                    await healthKitManager.requestWaterSamples(from: Date().addingTimeInterval(-86400 * 8), to: Date().addingTimeInterval(86400))
                    logger.info("Got HK Water Intake for 8 days")
                    await healthKitManager.requestDailyWaterIntake(to: Date().addingTimeInterval(-86400))
                    logger.info("Got HK Water intake for 24 hours")
                }
            }, label: {
                Text("Get Intake")
                    .padding(5)
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 5).stroke(Color.blue, lineWidth: 1))
            })
            Text("HK water intake Yesterday \( healthKitManager.waterIntake)")
            
            if healthKitManager.dailyWaterIntake.isEmpty {
                Text("No weekly data")
            } else {
//                Text("Weekly Water Intake: \(healthKitManager.dailyWaterIntake)")
                
            }
        }
        .padding(20)
//        .background(Color.gray.opacity(0.2))
        .environment(healthKitManager)
    }
}

#Preview {
    DisplayHKHistory()
        .environment(HealthKitManager())
}
