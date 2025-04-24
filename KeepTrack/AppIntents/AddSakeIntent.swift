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
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let commonEntry: CommonEntry = CommonEntry(id: UUID(), date: Date(), units: matchingUnitsDictionary["Sake"] ?? "Sake", amount: matchingAmountDictionary["Sake"] ?? 3.5, name: "Sake", goalMet: false)
        await KeepTrack.CommonStore().addEntry(entry: commonEntry)
        let snippetView: some View = VStack {
            Text("Nihon-shu added")
            Text("You have consumed a 3.5 ounce glasses of sake")
        }
        return .result(dialog: "Okay one glass of sake added",
                       view: snippetView)
    }
}
