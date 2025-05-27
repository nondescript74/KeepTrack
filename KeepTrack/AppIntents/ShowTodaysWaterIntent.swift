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
    static let title: LocalizedStringResource = "Show Todays Water"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
         
        let resultW = await KeepTrack.CommonStore().history.filter {
            (Calendar.current.isDateInToday($0.date))
        }.filter { $0.name.lowercased().contains("water")}
        logger.info("water consumed in app history is \(resultW))")
        return .result(dialog: "Okay, App shows you consumed \(resultW.count)  glasses of water today.")
    }
}
