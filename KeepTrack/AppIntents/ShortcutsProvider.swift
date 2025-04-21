//
//  ShortcutsProvider.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/24/25.
//

import AppIntents

struct KeepTrackShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddWaterIntent(),
            phrases: [
                "\(.applicationName) add water",
                "\(.applicationName) drank water"
            ],
            shortTitle: "Add water",
            systemImageName: "wineglass"
        )
        AppShortcut(
            intent: ShowTodaysWaterIntent(),
            phrases: [
                "\(.applicationName) show water",
                "\(.applicationName) todays water",
                "\(.applicationName) check water"
            ],
            shortTitle: "show water",
            systemImageName: "wineglass"
        )
    }
}
