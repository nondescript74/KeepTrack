//
//  AddEveningMedsIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 6/1/25.
//

import AppIntents
import SwiftUI

struct AddEveningMedsIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Add two meds"
    static var description: LocalizedStringResource? = "This adds metformin and latanoprost"
    
    
    func getPreviousIntake(typeName: String) async -> Int {
        let result = await KeepTrack.CommonStore().history.filter {
            (Calendar.current.isDateInToday($0.date))
        }.filter { $0.name.lowercased().contains(typeName.lowercased())}
        return result.count
    }
    
    func getGoal(typeName: String) async -> CommonGoal? {
        let result = await KeepTrack.CommonGoals().getTodaysGoalForName(namez: typeName)
        return result  // can be nil
    }
    
    func localGoalMet(typeName: String) async -> Bool {
        let result = await getGoal(typeName: typeName) != nil ? isGoalMet(goal: getGoal(typeName: typeName)!, previous: getPreviousIntake(typeName: typeName)) : true
        return result
    }
        
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let commonEntryMetformin: CommonEntry = await CommonEntry(id: UUID(), date: Date(), units: matchingUnitsDictionary["Metformin"] ?? "mg", amount: matchingAmountDictionary["Metformin"] ?? 500, name: "Metformin", goalMet: localGoalMet(typeName: "Metformin"))
        await KeepTrack.CommonStore().addEntry(entry: commonEntryMetformin)
        
        let commonEntryLatanoProst: CommonEntry = await CommonEntry(id: UUID(), date: Date(), units: matchingUnitsDictionary["Latanoprost"] ?? "mg", amount: matchingAmountDictionary["Latanoprost"] ?? 1, name: "Latanoprost", goalMet: localGoalMet(typeName: "Latanoprost"))
        await KeepTrack.CommonStore().addEntry(entry: commonEntryLatanoProst)
        
        let snippetView: some View = VStack {
            Text("Metformin and Latanoprost added")
            Text("You have consumed your evening meds")
        }
        return .result(dialog: "Metforminand Latanoprost added",
                       view: snippetView)
    }
}
