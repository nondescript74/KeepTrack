//
//  NewDashboard.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/29/25.
//

import SwiftUI
import Foundation
import OSLog

struct NewDashboard: View {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "NewDashboard")
    
    @State private var store: CommonStore = CommonStore()
    @State private var goals: CommonGoals = CommonGoals()
    
    var body: some View {
        NavigationStack {
            TabView {
                
                Tab("Today", systemImage: "wineglass") {
                    HistoryToday()
                }
                
                Tab("Yesterday", systemImage: "wineglass") {
                    HistoryYesterday()
                }
                
                
                Tab("Add History", systemImage: "heart.text.clipboard") {
                    ChangeHistory()
                }
                
                Tab("Show Goals", systemImage: "wineglass") {
                    GoalDisplayByName()
                }
                
                Tab("Goal", systemImage: "microphone.badge.plus") {
                    EnterGoal()
                }
                
                Tab("History", systemImage: "heart.text.clipboard") {
                    EditHistory(items: $store.history)
                }
                
                Tab("Edit Goals", systemImage: "figure.hockey") {
                    EditGoals(items: $goals.goals)
                }
                
                Tab("Add New", systemImage: "person") {
                    AddIntakeType()
                }
            }
            .padding(10)
            HStack {
                Text("Welcome to KeepTrack!")
                Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                Text(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
            }
            .font(.subheadline)
        }
        
        .padding()
        .environment(store)
        .environment(goals)
    }
}

#Preview {
    NewDashboard()
        .environment(CommonGoals())
        .environment(CommonStore())
}
