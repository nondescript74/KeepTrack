//
//  AddSomethingIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 8/19/25.
//

import AppIntents
import SwiftUI
import OSLog

import AppIntents

struct IntakeTypeOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        // Use MainActor to safely access CurrentIntakeTypes
        await MainActor.run {
            let types = CurrentIntakeTypes().intakeTypeNameArray
            logger.info("Current intake types: \(types)")
            return types.isEmpty ? ["Water"] : types
        }
    }
}

struct AddSomethingIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Something"
    static var description: LocalizedStringResource? = "Add a selected intake item to your history."
    
    @Parameter(
        title: "Item to Add",
        description: "Select the intake to add to your log.",
        optionsProvider: IntakeTypeOptionsProvider()
    )
    var intakeType: String

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$intakeType) (must specify intake type)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let cIntakeTypes = CurrentIntakeTypes()
        let name = intakeType
        let validTypes = cIntakeTypes.intakeTypeNameArray
        
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "AppIntents")
        logger.info("Available intake types: \(validTypes.joined(separator: ", "))")
        
        guard validTypes.map({ $0.lowercased() }).contains(name.lowercased()) else {
            let validList = validTypes.joined(separator: ", ")
            return .result(dialog: "The intake type you specified (\(name)) is not valid. Valid types are: \(validList). Please try again with a valid type.")
        }
        
        // Load the store asynchronously to ensure the latest state is loaded and changes persist correctly
        let store = await KeepTrack.CommonStore.loadStore()
        // Load goals for any goal-related logic
        _ = KeepTrack.CommonGoals()

        let units = cIntakeTypes.getunits(typeName: name)
        let amount = cIntakeTypes.getamount(typeName: name)
        
        let entry = CommonEntry(
            id: UUID(),
            date: Date(),
            units: units,
            amount: amount,
            name: name,
            goalMet: false // Optionally, calculate if the goal was met, using goals as needed
        )
        // Add the entry to the asynchronously loaded store instance
        store.addEntry(entry: entry)
        
        let snippetView: some View = VStack {
            Text("\(name) added")
            Text("You logged a \(amount) \(units) serving of \(name).")
        }
        
        return .result(
            dialog: "Okay, added \(name).",
            view: snippetView
        )
    }
}

