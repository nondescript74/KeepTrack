// Create a new file that exposes your AddSomethingIntent to the system as an App Shortcut, using the modern AppShortcutsProvider approach.
// This file should be placed at the top level of your app target.

import SwiftUI
import AppIntents

struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] = [
        AppShortcut(
            intent: AddSomethingIntent(),
            phrases: ["Add intake ${applicationName}", "Add something in ${applicationName}"],
            shortTitle: "Add Intake",
            systemImageName: "plus.circle.fill"
        ),
        AppShortcut(
            intent: AddMorningMedsIntent(),
            phrases: ["Add morning meds ${applicationName}", "Add morning meds in ${applicationName}"],
            shortTitle: "Add Morning Meds",
            systemImageName: "pills.fill"
        )
        
    ]
}
