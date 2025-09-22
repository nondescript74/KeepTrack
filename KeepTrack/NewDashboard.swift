//
//  NewDashboard.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/29/25.
//

import SwiftUI
import Foundation
import OSLog

struct PendingNotification: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let goalDate: Date
}

struct NewDashboard: View {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "NewDashboard")
    
    @State private var store: CommonStore = CommonStore()
    @State private var goals: CommonGoals = CommonGoals()
    @Binding var pendingNotification: PendingNotification?
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var cIntakeTypes: CurrentIntakeTypes
    
    var body: some View {
        NavigationStack {
            TabView {
                
//                Tab("Intake", systemImage: "wineglass") {
//                    EnterIntake()
//                }
                
                Tab("Today", systemImage: "clipboard") {
                    HistoryDayView(kind: .today)
                }
                
                Tab("Yesterday", systemImage: "clipboard.fill") {
                    HistoryDayView(kind: .yesterday)
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await store.loadHistory()
                }
            }
        }
        .sheet(item: $pendingNotification) { notification in
            VStack(spacing: 24) {
                Text("Did you take your \(notification.name) at \(notification.goalDate.formatted(date: .omitted, time: .shortened))?")
                HStack {
                    Button("Confirm") {
                        Task {
                            // Search store.history for an entry matching name and date within 30 minutes
                            if let index = store.history.firstIndex(where: { entry in
                                entry.name == notification.name && abs(entry.date.timeIntervalSince(notification.goalDate)) < 1800
                            }) {
                                store.history[index].goalMet = true
                                await store.save()
                            } else {
                                let intakeType = cIntakeTypes.intakeTypeArray.first(where: { $0.name == notification.name })
                                let entry = CommonEntry(
                                    id: UUID(),
                                    date: notification.goalDate,
                                    units: intakeType?.unit ?? "units",
                                    amount: intakeType?.amount ?? 0.0,
                                    name: notification.name,
                                    goalMet: true
                                )
                                await store.addEntry(entry: entry)
                            }
                            pendingNotification = nil
                        }
                    }
                    Button("Cancel") {
                        pendingNotification = nil
                    }
                }
                .padding()
            }
            .padding()
        }
        .padding()
        .environment(store)
        .environment(goals)
    }
}

#Preview {
    NewDashboard(pendingNotification: .constant(nil as PendingNotification?))
        .environment(CommonGoals())
        .environment(CommonStore())
        .environmentObject(CurrentIntakeTypes())
}
