//
//  ShowMedsIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 6/1/25.
//

import AppIntents
import OSLog
import Foundation

struct ShowMedsIntent: AppIntent {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ShowMedsIntent")
    static let title: LocalizedStringResource = "Show all meds taken today"
    static let meds: [String] = ["amlodipine", "metformin", "rosuvastatin", "losartan", "latanoprost"]
    
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        let resultA = await KeepTrack.CommonStore().history.filter {
            (Calendar.current.isDateInToday($0.date))
        }.filter { $0.name.lowercased().contains("amlodipine")}
        logger.info("resultA is \(resultA))")
        
        let resultM = await KeepTrack.CommonStore().history.filter {
            (Calendar.current.isDateInToday($0.date))
        }.filter { $0.name.lowercased().contains("metformin")}
        logger.info("resultM is \(resultM))")
        
        let resultR = await KeepTrack.CommonStore().history.filter {
            (Calendar.current.isDateInToday($0.date))
        }.filter { $0.name.lowercased().contains("rosuvastatin")}
        logger.info("resultR is (\(resultR))")
        
        let resultL = await KeepTrack.CommonStore().history.filter {
            (Calendar.current.isDateInToday($0.date))
        }.filter { $0.name.lowercased().contains("losartan")}
        logger.info("resultL is (\(resultL))")
        
        let resultLa = await KeepTrack.CommonStore().history.filter {
            (Calendar.current.isDateInToday($0.date))
        }.filter { $0.name.lowercased().contains("latanoprost")}
        logger.info("resultL is (\(resultLa))")
        
        return .result(dialog: "Okay, you consumed \(resultA.count) amlopidine, \(resultM.count) metformin, \(resultR.count) rosuvastatin, \(resultL.count) losartan, and \(resultLa.count) latanoprost.")
    }
}
