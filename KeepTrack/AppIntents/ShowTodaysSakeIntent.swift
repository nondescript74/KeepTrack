//
//  ShowTodaysSakeIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/24/25.
//

import AppIntents
import OSLog

struct ShowTodaysSakeIntent: AppIntent {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ShowTodaysSakeIntent")
    static let title: LocalizedStringResource = "Show Todays Sake"
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let resultS = KeepTrack.CommonStore().history.filter {
            Calendar.current.isDateInToday($0.date)
        }.filter { $0.name.lowercased().contains("sake") }
        logger.info("sake consumed is \(resultS)")
        return .result(dialog: "Okay, you consumed \(resultS.count) glasses of sake today.")
    }
}
