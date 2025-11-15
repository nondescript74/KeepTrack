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
    
    @State private var selectedTab: TabSelection = .today
    @State private var showingHelp = false
    
    private enum TabSelection {
        case today, yesterday, byDayTime, addHistory, showGoals, enterGoal, editHistory, editGoals, addNew
        
        var helpIdentifier: HelpViewIdentifier {
            switch self {
            case .today: return .today
            case .yesterday: return .yesterday
            case .byDayTime: return .consumptionByDayAndTime
            case .addHistory: return .addHistory
            case .showGoals: return .showGoals
            case .enterGoal: return .enterGoal
            case .editHistory: return .editHistory
            case .editGoals: return .editGoals
            case .addNew: return .addIntakeType
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {

                Tab("Today", systemImage: "clipboard", value: .today) {
                    HistoryDayView(kind: .today)
                        .onAppear { selectedTab = .today }
                }
                
                Tab("Yesterday", systemImage: "clipboard.fill", value: .yesterday) {
                    HistoryDayView(kind: .yesterday)
                        .onAppear { selectedTab = .yesterday }
                }
                
                Tab("Add History", systemImage: "heart.text.clipboard", value: .addHistory) {
                    ChangeHistory()
                        .onAppear { selectedTab = .addHistory }
                }
                
                Tab("Show Goals", systemImage: "wineglass", value: .showGoals) {
                    GoalDisplayByName()
                        .onAppear { selectedTab = .showGoals }
                }
                
                Tab("Goal", systemImage: "microphone.badge.plus", value: .enterGoal) {
                    EnterGoal()
                        .onAppear { selectedTab = .enterGoal }
                }
                
                Tab("History", systemImage: "heart.text.clipboard", value: .editHistory) {
                    EditHistory(items: $store.history)
                        .onAppear { selectedTab = .editHistory }
                }
                
                Tab("Edit Goals", systemImage: "figure.hockey", value: .editGoals) {
                    EditGoals(items: $goals.goals)
                        .onAppear { selectedTab = .editGoals }
                }
                
                Tab("Add New", systemImage: "person", value: .addNew) {
                    AddIntakeType()
                        .onAppear { selectedTab = .addNew }
                }
            }
            .padding(10)
            .onChange(of: selectedTab) { oldValue, newValue in
                logger.debug("Tab changed from \(String(describing: oldValue)) to \(String(describing: newValue))")
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HStack {
                    Text("Welcome to KeepTrack!")
                    Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                    Text(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
                }
                .font(.subheadline)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        logger.debug("Help button tapped for tab: \(String(describing: selectedTab))")
                        showingHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("Show help for this screen")
                }
            }
            .sheet(isPresented: $showingHelp) {
                HelpView(topic: HelpContentManager.getHelpTopic(for: selectedTab.helpIdentifier))
            }
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
