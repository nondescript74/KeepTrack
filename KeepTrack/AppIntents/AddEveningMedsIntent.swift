//
//  AddEveningMedsIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 6/1/25.
//

import AppIntents
import SwiftUI

struct AddEveningMedsIntent: AppIntent {
    
    static let title: LocalizedStringResource = "Add one med"
    static var description: LocalizedStringResource? = "This adds latanoprost"
    
    
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
        
        let commonEntryLatanoProst: CommonEntry = await CommonEntry(id: UUID(), date: Date(), units: "drop", amount: 1, name: "Latanoprost", goalMet: localGoalMet(typeName: "Latanoprost"))
        await KeepTrack.CommonStore().addEntry(entry: commonEntryLatanoProst)
        
        let snippetView: some View = VStack {
            Text("You have consumed latanoprost")
        }
        return .result(dialog: "Latanoprost added",
                       view: snippetView)
    }
}
