//
//  KeepTrackApp.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/18/25.
//

import SwiftUI

@main
struct KeepTrackApp: App {
    @StateObject private var currentIntakeTypes = CurrentIntakeTypes()
    var body: some Scene {
        WindowGroup {
            NewDashboard()
                .environmentObject(currentIntakeTypes)
        }
    }
}
