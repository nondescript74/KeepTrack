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
            systemImageName: "waterbottle.fill"
        )
        AppShortcut(
            intent: AddSakeIntent(),
            phrases: [
                "\(.applicationName) add sake",
                "\(.applicationName) drank sake"
            ],
            shortTitle: "Add sake",
            systemImageName: "wineglass"
        )
        AppShortcut(
            intent: AddMorningMedsIntent(),
            phrases: [
                "\(.applicationName) add morning meds",
                "\(.applicationName) took morning meds"
            ],
            shortTitle: "Add morning meds",
            systemImageName: "pills.fill"
        )
        AppShortcut(
            intent: AddEveningMedsIntent(),
            phrases: [
                "\(.applicationName) add evening meds",
                "\(.applicationName) took evening meds"
            ],
            shortTitle: "Add evening meds",
            systemImageName: "pills.fill"
        )
        AppShortcut(
            intent: ShowTodaysWaterIntent(),
            phrases: [
                "\(.applicationName) show water",
                "\(.applicationName) todays water",
                "\(.applicationName) check water"
            ],
            shortTitle: "show water",
            systemImageName: "waterbottle"
        )
        AppShortcut(
            intent: ShowTodaysSakeIntent(),
            phrases: [
                "\(.applicationName) show sake",
                "\(.applicationName) todays sake",
            ],
            shortTitle: "show sake",
            systemImageName: "wineglass.fill"
        )
        AppShortcut(
            intent: ShowMedsIntent(),
            phrases: [
                "\(.applicationName) show meds",
                "\(.applicationName) all meds",
            ],
            shortTitle: "show meds",
            systemImageName: "pills"
        )
    }
}
