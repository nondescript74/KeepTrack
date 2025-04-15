//
//  ShowTodaysWater.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/24/25.
//

import AppIntents

struct ShowTodaysWater: AppIntent {
    static let title: LocalizedStringResource = "Show Todays Water"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = await KeepTrack.CommonStore().history.filter { $0.date == Date.now }.filter { $0.name.lowercased().contains("water")}
        return .result(dialog: "Okay, you consumed \(result.count) 14 oz glasses of water today.")
    }
    
}
