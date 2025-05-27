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
            
            HStack {
                Button(action: {
                    // perform query from here
                     logger.info("Getting HK Water Intake History")
                },
                       label: {Text("Get Intake")
                        .padding(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 1))}
                )
                 
                Button(action: {
                    showDetail.toggle()
                    if showDetail {
                        logger.info("showDetail is true")
                    } else {
                        logger.info( "showDetail is false")
                    }
                },
                       label: {Text("show/hide")
                        .padding(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 1))}
                )
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.2))
        .environment(healthKitManager)
    }
}

#Preview {
    DisplayHKHistory()
        .environment(HealthKitManager())
}
