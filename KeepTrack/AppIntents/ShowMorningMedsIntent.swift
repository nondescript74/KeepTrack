//
//  ShowMorningMedsIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/24/25.
//

import AppIntents
import OSLog
import Foundation

struct ShowMorningMedsIntent: AppIntent {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ShowMorningMedsIntent")
    static let title: LocalizedStringResource = "Show morning meds"
    static let morningMeds: [String] = ["amlodipine", "timolol", "rosuvastatin", "losartan"]
    
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let history = KeepTrack.CommonStore().history.filter {
            Calendar.current.isDateInToday($0.date)
        }
        
        let resultA = history.filter { $0.name.lowercased().contains("amlodipine") }
        logger.info("resultA is \(resultA)")
        
        let resultR = history.filter { $0.name.lowercased().contains("rosuvastatin") }
        logger.info("resultR is \(resultR)")
        
        let resultL = history.filter { $0.name.lowercased().contains("losartan") }
        logger.info("resultL is \(resultL)")
        
        let resultT = history.filter { $0.name.lowercased().contains("timolol") }
        logger.info("resultT is \(resultT)")
        
        return .result(dialog: "Okay, you consumed \(resultA.count) amlodipine, \(resultT.count) timolol, \(resultR.count) rosuvastatin, and \(resultL.count) losartan")
    }
}
