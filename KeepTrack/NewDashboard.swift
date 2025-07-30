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
    @State private var cIntakeTypes = CurrentIntakeTypes()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Text("Welcome to KeepTrack!")
                    Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                    Text(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
                }
                .font(.subheadline)
                
                Divider()
                
                HistoryToday()
                
                HistoryYesterday()
                
                Divider()
            
            }
            TabView {
                Tab("Intake", systemImage: "wineglass") {
                    EnterIntake()
                }
                
                Tab("Goal", systemImage: "microphone.badge.plus") {
                    EnterGoal()
                }
                
                Tab("Add History", systemImage: "heart.text.clipboard") {
                    ChangeHistory()
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
        }
        
        .padding()
        .environment(store)
        .environment(goals)
        .environment(cIntakeTypes)
    }
}

#Preview {
    NewDashboard()
        .environment(CommonGoals())
        .environment(CommonStore())
        .environment(CurrentIntakeTypes())
}
