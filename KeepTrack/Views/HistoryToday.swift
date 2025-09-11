//
//  HistoryToday.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/30/25.
//

import SwiftUI
import OSLog

struct HistoryToday: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "History")
    @Environment(CommonStore.self) private var store
    @Environment(CommonGoals.self) private var goals
    @EnvironmentObject private var cIntakeTypes: CurrentIntakeTypes
    
    @State private var toggeled: Bool = false
    
    fileprivate func getToday() -> [CommonEntry] {
        let myReturn = store.history.filter { Calendar.current.isDateInToday($0.date) }
//        logger.info("gT\(myReturn.count)")
        return myReturn
    }
    
    fileprivate func sortTodayByName(name: String) -> [CommonEntry] {
        let myReturn  = getToday().filter { $0.name.lowercased() == name.lowercased() }.sorted { $0.date < $1.date }
//        logger.info("sTBN \(myReturn.count)")
        return myReturn
    }
    
    fileprivate func getUniqueTodaysCommonEntriesUntilNow(name: String) -> [CommonEntry] {
        let myReturn: [CommonEntry] = sortTodayByName(name: name)
//        logger.info("gUTCEUN \(myReturn.debugDescription)")
        return myReturn
    }
    
    func getTypeColor(intakeType: IntakeType) -> Color {
        let types = cIntakeTypes.sortedIntakeTypeArray
        let index = types.firstIndex(of: intakeType)!
        return colors[index]
    }
    
    var body: some View {
        ZStack {
            // Beautiful background with glass effect
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.25), Color.purple.opacity(0.18), Color.white]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            .overlay(.ultraThinMaterial)
            
            VStack(spacing: 18) {
                Text("Today")
                    .font(.largeTitle).bold()
                    .foregroundStyle(Color.blue)
                    .shadow(color: .blue.opacity(0.2), radius: 4, x: 0, y: 2)
                    .padding(.top, 10)
                
                if getToday().isEmpty {
                    Text("Nothing taken today")
                        .foregroundColor(.red)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }
                
                // Intake list section with glassy card effect
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.65), Color.blue.opacity(0.12)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                    .shadow(radius: 3, y: 2)
                    .overlay(
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(cIntakeTypes.sortedIntakeTypeArray, id: \.self) { type in
                                    if !sortTodayByName(name: type.name).isEmpty {
                                        HStack {
                                            Text("\(type.name): ")
                                                .foregroundStyle(getTypeColor(intakeType: type))
                                                .font(.subheadline)
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack {
                                                    ForEach(getUniqueTodaysCommonEntriesUntilNow(name: type.name)) { entry in
                                                        Clock(hour: getHour(from: entry.date), minute: getMinute(from: entry.date), is12HourFormat: true, isAM: isItAM(date: entry.date), colorGreen: entry.goalMet)
                                                    }
                                                    .font(.caption2)
                                                    .padding([.bottom, .top], 1)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 8)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .padding(.vertical, 2)
                    )
                    .padding(.horizontal, 14)
                    .padding(.top, 2)
                
                Divider().opacity(0.38)
                    .padding(.horizontal, 30)
                
                // Intake entry section, glass+gradient background
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.10), Color.white.opacity(0.45)]), startPoint: .top, endPoint: .bottomTrailing))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                    .shadow(radius: 2, y: 1)
                    .overlay(
                        VStack {
                            EnterIntake()
                        }
//                        .padding(.vertical, 4)
//                        .padding(.horizontal, 4)
                    )
                    .padding(.horizontal, 12)
                
                Divider().opacity(0.24)
                    .padding(.horizontal, 10)
            }
            .padding(.bottom, 10)
        }
        .environment(store)
        .environment(goals)
        // Schedule notifications for today's goals when the view appears or updates
        .task {
            for goal in goals.getTodaysGoals() {
                IntakeReminderManager.scheduleReminder(for: goal, store: store)
            }
        }
    }
    
}

#Preview {
    HistoryToday()
        .environment(CommonStore())
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}

