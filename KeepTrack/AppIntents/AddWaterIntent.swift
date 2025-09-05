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
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        // Load the shared CommonStore asynchronously to ensure safe, correct data persistence
        // Also get the shared CommonGoals instance to access today's goals
        let store = await KeepTrack.CommonStore.loadStore()
        let goals = KeepTrack.CommonGoals()
        
        // Use the loaded store instance for all data retrieval and mutation
        let previous: Int = store.getTodaysIntake().count
        
        // Use the loaded goals instance to get today's goal for "Water"
        let goal: CommonGoal? = goals.getTodaysGoalForName(namez: "Water") ?? nil
        
        // Create a new entry with goalMet evaluated using the loaded goal and previous intake count
        let commonEntry = CommonEntry(
            id: UUID(),
            date: Date(),
            units: "fluid ounces",
            amount: 14,
            name: "Water",
            goalMet: (goal == nil) ? true : isGoalMet(goal: goal!, previous: previous)
        )
        
        // Add the new entry to the loaded store instance
        store.addEntry(entry: commonEntry)
        
        let snippetView: some View = VStack {
            Text("Intake added")
            Text("You added a 14 ounce glass of water")
        }
        
        return .result(
            dialog: "14 ounces of water added",
            view: snippetView
        )
    }
}
