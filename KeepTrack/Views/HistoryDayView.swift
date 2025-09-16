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
        ZStack {
            // Dynamic gradient/background depending on kind
//            if kind == .today {
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.blue.opacity(0.25), Color.purple.opacity(0.18), Color.white]),
//                    startPoint: .top, endPoint: .bottom
//                )
//                .overlay(.ultraThinMaterial)
//            } else {
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.purple.opacity(0.19), Color.blue.opacity(0.23), Color.white]),
//                    startPoint: .top, endPoint: .bottom
//                )
//                .overlay(.ultraThinMaterial)
//            }
        
            VStack(spacing: kind == .today ? 18 : 20) {
                Text(kind == .today ? "Today" : "Yesterday")
                    .font(.title).bold()
                    .foregroundStyle(Color.blue)
                    .shadow(color: .blue.opacity(kind == .today ? 0.2 : 0.18), radius: 4, x: 0, y: 2)
                    //.padding(.top, kind == .today ? 0 : 10)
                
                if getEntries().isEmpty {
                    Text(kind == .today ? "Nothing taken today" : "No entries yet")
                        .foregroundColor(.red)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(.horizontal, 24)
                        //.padding(.top, kind == .today ? 0 : 8)
                }
                
                // Intake list section with glassy card effect
//                RoundedRectangle(cornerRadius: 28, style: .continuous)
//                    .fill(
//                        LinearGradient(
//                            gradient: Gradient(colors: [
//                                Color.white.opacity(kind == .today ? 0.65 : 0.60),
//                                (kind == .today ? Color.blue.opacity(0.12) : Color.purple.opacity(0.13))
//                            ]),
//                            startPoint: .topLeading, endPoint: .bottomTrailing
//                        )
//                    )
//                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
//                    .shadow(radius: 3, y: 2)
//                    .overlay(
                        ScrollView {
                            VStack(spacing: 10) {
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
                                                    }
                                                    .font(.caption2)
//                                                    .padding([.bottom, .top], 1)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 8)
                                    }
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 28))
//                    )
//                    .padding(.horizontal, 14)

                if kind == .today {
                    // Today also schedules reminders
                    // Schedule notifications for today's goals when the view appears or updates
                    EmptyView()
                } else {
                    Spacer(minLength: 28)
                }
            }
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
    }
}

#Preview {
    HistoryDayView(kind: .today)
        .environment(CommonStore())
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
