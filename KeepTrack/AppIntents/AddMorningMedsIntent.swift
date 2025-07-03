//
//  AddMorningMedsIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/24/25.
//

import AppIntents
import SwiftUI

struct AddMorningMedsIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Add morning meds"
    static var description: LocalizedStringResource? = "This adds Amlodipine, Losartan, and Rosuvastatin"
    
    
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
        
        let commonEntryLosartan: CommonEntry = await CommonEntry(id: UUID(), date: Date(), units: "mg", amount: 25, name: "Losartan", goalMet: localGoalMet(typeName: "Losartan"))
        await KeepTrack.CommonStore().addEntry(entry: commonEntryLosartan)
        
        let commonEntryRosuvastatin: CommonEntry = await CommonEntry(id: UUID(), date: Date(), units: "mg", amount: 20, name: "Rosuvastatin", goalMet: localGoalMet(typeName: "Rosuvastatin"))
        await KeepTrack.CommonStore().addEntry(entry: commonEntryRosuvastatin)
        
        let commonEntryAmlodipine: CommonEntry = await CommonEntry(id: UUID(), date: Date(), units: "mg", amount: 5, name: "Amlodipine", goalMet: localGoalMet(typeName: "Amlodipine"))
        await KeepTrack.CommonStore().addEntry(entry: commonEntryAmlodipine)
        
        let snippetView: some View = VStack {
            Text("Losartan, Rosuvastatin, Amlodipine added")
            Text("You have consumed your morning meds")
        }
        return .result(dialog: "Losartan, Rosuvastatin, Amlodipine added",
                       view: snippetView)
    }
}
