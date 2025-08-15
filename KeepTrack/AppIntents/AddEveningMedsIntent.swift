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
        let myName = "Latanoprost"
        let commonEntryLatanoProst = CommonEntry(
            id: UUID(),
            date: Date(),
            units: "drop",
            amount: 1,
            name: myName,
            goalMet: localGoalMet(typeName: myName)
        )
        KeepTrack.CommonStore().addEntry(entry: commonEntryLatanoProst)
        
        let snippetView: some View = VStack {
            Text("You have consumed latanoprost")
        }
        return .result(dialog: "Latanoprost added",
                       view: snippetView)
    }
}
