//  HistoryDayView.swift
//  KeepTrack
//
//  Created by refactor on 9/12/25.
//

import SwiftUI
import OSLog

/// Which day to display
enum HistoryDayKind {
    case today
    case yesterday
}

struct HistoryDayView: View {
    let kind: HistoryDayKind
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "History")
    @Environment(CommonStore.self) private var store
    @Environment(CommonGoals.self) private var goals
    @EnvironmentObject private var cIntakeTypes: CurrentIntakeTypes

    fileprivate func getEntries() -> [CommonEntry] {
        switch kind {
        case .today:
            return store.history.filter { Calendar.current.isDateInToday($0.date) }
        case .yesterday:
            return store.history.filter { Calendar.current.isDateInYesterday($0.date) }
        }
    }

    fileprivate func sortEntriesByName(name: String) -> [CommonEntry] {
        getEntries().filter { $0.name.lowercased() == name.lowercased() }.sorted { $0.date < $1.date }
    }

    fileprivate func getUniqueEntriesForName(name: String) -> [CommonEntry] {
        // You could add extra uniqueness logic here if needed
        sortEntriesByName(name: name)
    }

    func getTypeColor(intakeType: IntakeType) -> Color {
        let types = cIntakeTypes.sortedIntakeTypeArray
        let index = types.firstIndex(of: intakeType) ?? 0
        return colors[index]
    }

    var body: some View {
        VStack(spacing: 0) {
            if kind == .today {
                EnterIntake()
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(.thinMaterial)
            }

            Text(kind == .today ? "Today" : "Yesterday")
                .font(.title).bold()
                .foregroundStyle(.blue)
                .shadow(color: .blue.opacity(kind == .today ? 0.2 : 0.18), radius: 4, x: 0, y: 2)
                .padding(.bottom, kind == .today ? 18 : 20)

            if getEntries().isEmpty {
                Text(kind == .today ? "Nothing taken today" : "No entries yet")
                    .foregroundColor(.red)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 24)
            }
            ScrollView {
                VStack(spacing: 10) {
                    Group {
                        ForEach(cIntakeTypes.sortedIntakeTypeArray, id: \.self) { type in
                            if !sortEntriesByName(name: type.name).isEmpty {
                                HStack {
                                    Text("\(type.name): ")
                                        .foregroundStyle(getTypeColor(intakeType: type))
                                        .font(.headline)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(getUniqueEntriesForName(name: type.name)) { entry in
                                                DigitalClockView(hour: getHour(from: entry.date), minute: getMinute(from: entry.date), is12HourFormat: true, isAM: isItAM(date: entry.date), colorGreen: entry.goalMet)
                                                    .transition(.move(edge: .top).combined(with: .opacity))
                                            }
                                            .font(.caption2)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .animation(kind == .today ? .default : nil, value: getEntries())
                }
                .padding(.bottom, 8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(.top, 16)
            .background(.ultraThinMaterial)
        }
        .environment(store)
        .environment(goals)
        .task {
            if kind == .today {
                for goal in goals.getTodaysGoals() {
                    IntakeReminderManager.scheduleReminder(for: goal, store: store)
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    HistoryDayView(kind: .today)
        .environment(CommonStore())
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
