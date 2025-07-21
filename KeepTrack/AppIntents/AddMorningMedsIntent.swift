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
        let currentIntakeTypes = CurrentIntakeTypes()
        
        var myName: String = "losartan"
        let commonEntryLosartan: CommonEntry = await CommonEntry(id: UUID(), date: Date(), units: currentIntakeTypes.getunits(typeName: myName), amount: currentIntakeTypes.getamount(typeName: myName), name: myName, goalMet: localGoalMet(typeName: myName))
        await KeepTrack.CommonStore().addEntry(entry: commonEntryLosartan)
        
        myName = "rosuvastatin"
        let commonEntryRosuvastatin: CommonEntry = await CommonEntry(id: UUID(), date: Date(), units: currentIntakeTypes.getunits(typeName: myName), amount: currentIntakeTypes.getamount(typeName: myName), name: myName, goalMet: localGoalMet(typeName: myName))
        await KeepTrack.CommonStore().addEntry(entry: commonEntryRosuvastatin)
        
        myName = "timolol"
        let commonEntryTimolol: CommonEntry = await CommonEntry(id: UUID(), date: Date(), units: currentIntakeTypes.getunits(typeName: myName), amount: currentIntakeTypes.getamount(typeName: myName), name: myName, goalMet: localGoalMet(typeName: myName))
        await KeepTrack.CommonStore().addEntry(entry: commonEntryTimolol)
        
        myName = "amlodipine"
        let commonEntryAmlodipine: CommonEntry = await CommonEntry(id: UUID(), date: Date(), units: currentIntakeTypes.getunits(typeName: myName), amount: currentIntakeTypes.getamount(typeName: myName), name: myName, goalMet: localGoalMet(typeName: myName))
        await KeepTrack.CommonStore().addEntry(entry: commonEntryAmlodipine)
        
        let snippetView: some View = VStack {
            Text("Losartan, Rosuvastatin, Timolol, Amlodipine added")
            Text("You have consumed your morning meds")
        }
        return .result(dialog: "Losartan, Rosuvastatin, Timolol, Amlodipine added",
                       view: snippetView)
    }
}
