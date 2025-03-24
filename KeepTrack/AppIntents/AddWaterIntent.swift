//
//  AddWaterIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/22/25.
//

import AppIntents
import SwiftUI

struct AddWaterIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Water"
    static var description: LocalizedStringResource? = "This adds a glass of water to your intake"
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        await KeepTrack.Water().addWater(1)
        let todaysWater: Int = await KeepTrack.Water().showTodaysWater()
        let snippetView: some View = VStack {
            Text("Water added")
            Text("You have consumed \(todaysWater) glasses of water")
        }
        return .result(dialog: "Okay water added",
                       view: snippetView)
    }
}
