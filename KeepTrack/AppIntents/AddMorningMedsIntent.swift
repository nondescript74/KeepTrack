//
//  AddMorningMedsIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/24/25.
//

import AppIntents
import SwiftUI

struct AddMorningMedsIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Add four meds"
    static var description: LocalizedStringResource? = "This adds metformin, losartan, and rosuvastatin"
        
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let commonEntryMetformin: CommonEntry = CommonEntry(id: UUID(), date: Date(), units: matchingUnitsDictionary["Metformin"] ?? "mg", amount: matchingAmountDictionary["Metformin"] ?? 500, name: "Metformin", goalMet: false)
        await KeepTrack.CommonStore().addEntry(entry: commonEntryMetformin)
        
        let commonEntryLosartan: CommonEntry = CommonEntry(id: UUID(), date: Date(), units: matchingUnitsDictionary["Losartan"] ?? "mg", amount: matchingAmountDictionary["Losartan"] ?? 25, name: "Losartan", goalMet: false)
        await KeepTrack.CommonStore().addEntry(entry: commonEntryLosartan)
        
        let commonEntryRosuvastatin: CommonEntry = CommonEntry(id: UUID(), date: Date(), units: matchingUnitsDictionary["Rosuvastatin"] ?? "mg", amount: matchingAmountDictionary["Rosuvastatin"] ?? 20, name: "Rosuvastatin", goalMet: false)
        await KeepTrack.CommonStore().addEntry(entry: commonEntryRosuvastatin)
        
        let commonEntryAmlodipine: CommonEntry = CommonEntry(id: UUID(), date: Date(), units: matchingUnitsDictionary["Amlodipine"] ?? "mg", amount: matchingAmountDictionary["Amlodipine"] ?? 5, name: "Amlodipine", goalMet: false)
        await KeepTrack.CommonStore().addEntry(entry: commonEntryAmlodipine)
        
        let snippetView: some View = VStack {
            Text("Metformin, Losartan, Rosuvastatin, Amlodipine added")
            Text("You have consumed your morning meds")
        }
        return .result(dialog: "Okay Metformin, Losartan, Rosuvastatin, Amlodipine added",
                       view: snippetView)
    }
}
