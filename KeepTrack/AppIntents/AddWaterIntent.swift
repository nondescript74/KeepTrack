//
//  AddIntakeIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import AppIntents
import SwiftUI
import HealthKit

struct AddWaterIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Add Water"
    static var description: LocalizedStringResource? = "This adds a 14 oz glass of water"
    
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let commonEntry: CommonEntry = CommonEntry(id: UUID(), date: Date(), units: "fluid ounces", amount: 14, name: "Water", goalMet: false)
        await KeepTrack.CommonStore().addEntry(entry: commonEntry)
        let snippetView: some View = VStack {
            Text("Intake added")
            Text("You added a 14 ounce glasses of water")
        }
        let quantity: HKQuantity = HKQuantity(unit: .fluidOunceUS(), doubleValue: 14)
        
        await HealthKitManager().addWaterSample(quantity: quantity)
        
        return .result(dialog: "Okay 14 ounces of water added",
                       view: snippetView)
    }
}

