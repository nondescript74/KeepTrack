//
//  AddWaterIntent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/22/25.
//

import AppIntents

struct AddWaterIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Water"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        await KeepTrack.Water().addWater(1)
        return .result(dialog: "Okay, water added")
    }
}

struct KeepTrackShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddWaterIntent(),
            phrases: [
                "\(.applicationName) add water",
                "\(.applicationName) drank water"
            ],
            shortTitle: "Add water",
            systemImageName: "glass")
    }
}
