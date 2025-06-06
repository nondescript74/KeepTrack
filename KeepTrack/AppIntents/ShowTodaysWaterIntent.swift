//
//  ShowTodaysWaterIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/24/25.
//

import AppIntents
import OSLog
import HealthKit
import SwiftUI

struct ShowTodaysWaterIntent: AppIntent {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ShowTodaysWaterIntent")
    static let title: LocalizedStringResource = "Show Todays Liquid Intake"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
         
        let resultW = await KeepTrack.CommonStore().history.filter {
            (Calendar.current.isDateInToday($0.date))
        }.filter { $0.name.lowercased().contains("water")}
        
        let resultSm = await KeepTrack.CommonStore().history.filter {
            (Calendar.current.isDateInToday($0.date))
        }.filter { $0.name.lowercased().contains("smoothie")}
        
        logger.info("water consumed in app history is \(resultW))")
        logger.info("smoothies consumed in app history is \(resultSm))")
        
        return .result(dialog: "You consumed \(resultW.count)  glasses of water today and \(resultSm.count) smoothies.")
    }
}
