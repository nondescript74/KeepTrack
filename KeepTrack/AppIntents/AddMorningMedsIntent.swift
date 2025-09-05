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
    static var description: LocalizedStringResource? = "This adds Amlodipine, Losartan, Timolol and Rosuvastatin"
    
    // Refactored to take loaded store instance so we avoid multiple loads and use the awaited loaded store
    @MainActor
    func getPreviousIntake(typeName: String, store: KeepTrack.CommonStore) -> Int {
        let result = store.history.filter {
            Calendar.current.isDateInToday($0.date)
        }.filter { $0.name.lowercased().contains(typeName.lowercased()) }
        return result.count
    }
    
    @MainActor
    func getGoal(typeName: String, goals: KeepTrack.CommonGoals) -> CommonGoal? {
        let result = goals.getTodaysGoalForName(namez: typeName)
        return result  // can be nil
    }
    
    @MainActor
    func localGoalMet(typeName: String, goals: KeepTrack.CommonGoals, store: KeepTrack.CommonStore) -> Bool {
        if let goal = getGoal(typeName: typeName, goals: goals) {
            let previous = getPreviousIntake(typeName: typeName, store: store)
            return isGoalMet(goal: goal, previous: previous)
        } else {
            return true
        }
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        // Use await and loadStore() to get the fully loaded persistent store of data
        // Also load the goals store
        let store = await KeepTrack.CommonStore.loadStore()
        let goals = KeepTrack.CommonGoals()
        let currentIntakeTypes = CurrentIntakeTypes()
        
        var myName: String = "losartan"
        let commonEntryLosartan = CommonEntry(
            id: UUID(),
            date: Date(),
            units: currentIntakeTypes.getunits(typeName: myName),
            amount: currentIntakeTypes.getamount(typeName: myName),
            name: myName,
            goalMet: localGoalMet(typeName: myName, goals: goals, store: store)
        )
        store.addEntry(entry: commonEntryLosartan)
        
        myName = "rosuvastatin"
        let commonEntryRosuvastatin = CommonEntry(
            id: UUID(),
            date: Date(),
            units: currentIntakeTypes.getunits(typeName: myName),
            amount: currentIntakeTypes.getamount(typeName: myName),
            name: myName,
            goalMet: localGoalMet(typeName: myName, goals: goals, store: store)
        )
        store.addEntry(entry: commonEntryRosuvastatin)
        
        myName = "timolol"
        let commonEntryTimolol = CommonEntry(
            id: UUID(),
            date: Date(),
            units: currentIntakeTypes.getunits(typeName: myName),
            amount: currentIntakeTypes.getamount(typeName: myName),
            name: myName,
            goalMet: localGoalMet(typeName: myName, goals: goals, store: store)
        )
        store.addEntry(entry: commonEntryTimolol)
        
        myName = "amlodipine"
        let commonEntryAmlodipine = CommonEntry(
            id: UUID(),
            date: Date(),
            units: currentIntakeTypes.getunits(typeName: myName),
            amount: currentIntakeTypes.getamount(typeName: myName),
            name: myName,
            goalMet: localGoalMet(typeName: myName, goals: goals, store: store)
        )
        store.addEntry(entry: commonEntryAmlodipine)
        
        let snippetView: some View = VStack {
            Text("Losartan, Rosuvastatin, Timolol, Amlodipine added")
            Text("You have consumed your morning meds")
        }
        return .result(dialog: "Losartan, Rosuvastatin, Timolol, Amlodipine added",
                       view: snippetView)
    }
}

