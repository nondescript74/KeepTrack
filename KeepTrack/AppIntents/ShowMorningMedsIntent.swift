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
    
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let resultM = await KeepTrack.CommonStore().history.filter {
            compareDateComponents($0.date)
        }.filter { $0.name.lowercased().contains("metformin")}
        logger.info("resultM is \(resultM))")
        
        let resultR = await KeepTrack.CommonStore().history.filter {
            compareDateComponents($0.date)
        }.filter { $0.name.lowercased().contains("rosuvastatin")}
        logger.info("resultR is (\(resultR))")
        
        let resultL = await KeepTrack.CommonStore().history.filter {
            compareDateComponents($0.date)
        }.filter { $0.name.lowercased().contains("losartan")}
        logger.info("resultL is (\(resultL))")
        
        return .result(dialog: "Okay, you consumed \(resultM.count) metformin, \(resultR.count) rosuvastatin, and \(resultL.count) losartan")
    }
}
