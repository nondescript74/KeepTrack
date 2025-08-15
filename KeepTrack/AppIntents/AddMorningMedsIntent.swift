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
    
    @MainActor
    func getPreviousIntake(typeName: String) -> Int {
        let result = KeepTrack.CommonStore().history.filter {
            Calendar.current.isDateInToday($0.date)
        }.filter { $0.name.lowercased().contains(typeName.lowercased()) }
        return result.count
    }
    
    @MainActor
    func getGoal(typeName: String) -> CommonGoal? {
        let result = KeepTrack.CommonGoals().getTodaysGoalForName(namez: typeName)
        return result  // can be nil
    }
    
    @MainActor
    func localGoalMet(typeName: String) -> Bool {
        if let goal = getGoal(typeName: typeName) {
            let previous = getPreviousIntake(typeName: typeName)
            return isGoalMet(goal: goal, previous: previous)
        } else {
            return true
        }
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let currentIntakeTypes = CurrentIntakeTypes()
        
        var myName: String = "losartan"
        let commonEntryLosartan = CommonEntry(
            id: UUID(),
            date: Date(),
            units: currentIntakeTypes.getunits(typeName: myName),
            amount: currentIntakeTypes.getamount(typeName: myName),
            name: myName,
            goalMet: localGoalMet(typeName: myName)
        )
        KeepTrack.CommonStore().addEntry(entry: commonEntryLosartan)
        
        myName = "rosuvastatin"
        let commonEntryRosuvastatin = CommonEntry(
            id: UUID(),
            date: Date(),
            units: currentIntakeTypes.getunits(typeName: myName),
            amount: currentIntakeTypes.getamount(typeName: myName),
            name: myName,
            goalMet: localGoalMet(typeName: myName)
        )
        KeepTrack.CommonStore().addEntry(entry: commonEntryRosuvastatin)
        
        myName = "timolol"
        let commonEntryTimolol = CommonEntry(
            id: UUID(),
            date: Date(),
            units: currentIntakeTypes.getunits(typeName: myName),
            amount: currentIntakeTypes.getamount(typeName: myName),
            name: myName,
            goalMet: localGoalMet(typeName: myName)
        )
        KeepTrack.CommonStore().addEntry(entry: commonEntryTimolol)
        
        myName = "amlodipine"
        let commonEntryAmlodipine = CommonEntry(
            id: UUID(),
            date: Date(),
            units: currentIntakeTypes.getunits(typeName: myName),
            amount: currentIntakeTypes.getamount(typeName: myName),
            name: myName,
            goalMet: localGoalMet(typeName: myName)
        )
        KeepTrack.CommonStore().addEntry(entry: commonEntryAmlodipine)
        
        let snippetView: some View = VStack {
            Text("Losartan, Rosuvastatin, Timolol, Amlodipine added")
            Text("You have consumed your morning meds")
        }
        return .result(dialog: "Losartan, Rosuvastatin, Timolol, Amlodipine added",
                       view: snippetView)
    }
}
