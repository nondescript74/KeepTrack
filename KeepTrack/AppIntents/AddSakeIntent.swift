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
        // Load the shared persistent store asynchronously to ensure correct data saving and syncing
        let store = await KeepTrack.CommonStore.loadStore()
        // Initialize the common goals instance to check or update goals if needed
        _ = KeepTrack.CommonGoals()
        
        let commonEntry = CommonEntry(
            id: UUID(),
            date: Date(),
            units: "fluid ounces",
            amount: 3.5,
            name: "Sake",
            goalMet: false
        )
        store.addEntry(entry: commonEntry)
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
