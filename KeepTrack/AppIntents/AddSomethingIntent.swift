//
//  AddSomethingIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 8/19/25.
//

import AppIntents
import SwiftUI
import OSLog

// Direct-from-disk options provider (no dependency on app state)
struct IntakeTypeOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        let appGroupID = "group.com.headydiscy.KeepTrack"
        let fileName = "intakeTypes.json"

        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return ["Water"]
        }
        // let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.headydiscy.KeepTrack")

        let fileURL = containerURL.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let types = try JSONDecoder().decode([IntakeType].self, from: data)
                let names = types.map { $0.name }.sorted()
                return names.isEmpty ? ["Water"] : names
            } catch {
                return ["Water"]
            }
        } else {
            return ["Water"]
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
        let intakeTypes = loadIntakeTypesFromDisk()
        let validNames = intakeTypes.map { $0.name }
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "AppIntents")
        
        logger.info("Available intake types: \(validNames.joined(separator: ", "))")

        // Lookup selected intake type, ignoring case
        guard let matchedType = intakeTypes.first(where: { $0.name.caseInsensitiveCompare(intakeType) == .orderedSame }) else {
            let validList = validNames.joined(separator: ", ")
            return .result(dialog: "The intake type you specified (\(intakeType)) is not valid. Valid types are: \(validList). Please try again with a valid type.")
        }

        let store = await KeepTrack.CommonStore.loadStore()
        _ = KeepTrack.CommonGoals()
        
        let formattedAmount: String = {
            if matchedType.amount.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0f", matchedType.amount)
            } else {
                return String(format: "%.2f", matchedType.amount)
            }
        }()

        let entry = CommonEntry(
            id: UUID(),
            date: Date(),
            units: matchedType.unit,
            amount: matchedType.amount,
            name: matchedType.name,
            goalMet: false // Optionally, calculate if the goal was met, using goals as needed
        )
        await store.addEntry(entry: entry)
        
        let snippetView: some View = VStack {
            Text("\(matchedType.name) added")
            Text("You logged a \(formattedAmount) \(matchedType.unit) serving of \(matchedType.name).")
        }
        
        return .result(
            dialog: "Okay, added \(matchedType.name).",
            view: snippetView
        )
    }

    // Loads intake types directly from disk in the App Group container
    private func loadIntakeTypesFromDisk() -> [IntakeType] {
        let appGroupID = "group.com.headydiscy.KeepTrack"
        let fileName = "intakeTypes.json"
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return []
        }
        let fileURL = containerURL.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let types = try JSONDecoder().decode([IntakeType].self, from: data)
                return types
            } catch {
                return []
            }
        } else {
            return []
        }
    }
}
