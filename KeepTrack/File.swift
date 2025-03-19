//
//  File.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/18/25.
//

import Foundation
import OSLog

@Observable class WaterHistory {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "WaterHistory")
    var water: Int = 0
    
    func addWater(_ amount: Int) {
        water += amount
        logger.info("Added \(amount) units of water")
    }
    
    func removeWater(_ amount: Int) {
        if water < amount {
            logger.error( "Not enough water")
            return
        }
        logger.info( "Removed \(amount) units of water")
        water -= amount
    }
}
