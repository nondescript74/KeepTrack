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
        // Load the store asynchronously to ensure data is fully loaded before mutation
        let store = await KeepTrack.CommonStore.loadStore()
        // Load the goals model to access today's goals
        let goals = KeepTrack.CommonGoals()
        
        let myName = "Latanoprost"
        let commonEntryLatanoProst = CommonEntry(
            id: UUID(),
            date: Date(),
            units: "drop",
            amount: 1,
            name: myName,
            goalMet: localGoalMet(typeName: myName, goals: goals, store: store)
        )
        store.addEntry(entry: commonEntryLatanoProst)
        
        let snippetView: some View = VStack {
            Text("You have consumed latanoprost")
        }
        return .result(dialog: "Latanoprost added",
                       view: snippetView)
    }
}
