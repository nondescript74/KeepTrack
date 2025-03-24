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
        let result = await KeepTrack.Water().showTodaysWater()
        return .result(dialog: "Okay, you drank \(result) ounces of water today.")
    }
    
}
