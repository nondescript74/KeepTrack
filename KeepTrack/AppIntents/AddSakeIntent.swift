//
//  AddSakeIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/24/25.
//

import AppIntents
import SwiftUI

struct AddSakeIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Add Sake"
    static var description: LocalizedStringResource? = "This adds a 3.5 oz glass of sake"
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let commonEntry = CommonEntry(
            id: UUID(),
            date: Date(),
            units: "fluid ounces",
            amount: 3.5,
            name: "Sake",
            goalMet: false
        )
        KeepTrack.CommonStore().addEntry(entry: commonEntry)
        let snippetView: some View = VStack {
            Text("Nihon-shu added")
            Text("You have consumed a 3.5 fluid ounce glass of sake")
        }
        return .result(
            dialog: "Okay one glass of sake added",
            view: snippetView
        )
    }
}
