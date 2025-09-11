//
//  HistoryYesterday.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/30/25.
//

import SwiftUI
import OSLog

struct HistoryYesterday: View {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "History")
    @Environment(CommonStore.self) private var store
    @Environment(CommonGoals.self) private var goals
    @EnvironmentObject private var cIntakeTypes: CurrentIntakeTypes
    
    fileprivate func getYesterday() -> [CommonEntry] {
        let myReturn = store.history.filter { Calendar.current.isDateInYesterday($0.date) }
        logger.info("gY \(myReturn.count)")
        return myReturn
    }
    
    fileprivate func sortYesterdayByName(name: String) -> [CommonEntry] {
        let myReturn = getYesterday().filter { $0.name.lowercased() == name.lowercased() }.sorted { $0.date < $1.date }.uniqued()
        logger.info("sYBN \(myReturn.count)")
        return myReturn
    }
    
    func getTypeColor(intakeType: IntakeType) -> Color {
        let types = cIntakeTypes.sortedIntakeTypeArray
        let index = types.firstIndex(of: intakeType)!
        return colors[index]
    }
    
    fileprivate func getUniqueYesterdayByNameCount(name: String) -> Int {
        let myReturn: Int = sortYesterdayByName(name: name).count
        logger.info("gUYBNCount: \(myReturn)")
        return myReturn
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.19), Color.blue.opacity(0.23), Color.white]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            .overlay(.ultraThinMaterial)

            VStack(spacing: 20) {
                Text("Yesterday")
                    .font(.largeTitle).bold()
                    .foregroundStyle(Color.blue)
                    .shadow(color: .blue.opacity(0.18), radius: 4, x: 0, y: 2)
                    .padding(.top, 10)

                if getYesterday().isEmpty {
                    Text("No entries yet")
                        .foregroundColor(.red)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }
                // Intake list section with glassy card effect
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.60), Color.purple.opacity(0.13)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                    .shadow(radius: 2, y: 1)
                    .overlay(
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(cIntakeTypes.sortedIntakeTypeArray, id: \.self) { type in
                                    if !sortYesterdayByName(name: type.name).isEmpty {
                                        HStack {
                                            Text("\(type.name): ")
                                                .foregroundStyle(getTypeColor(intakeType: type))
                                                .font(.subheadline)
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack {
                                                    ForEach(sortYesterdayByName(name: type.name), id: \.self) { entry in
                                                        Clock(hour: getHour(from: entry.date), minute: getMinute(from: entry.date), is12HourFormat: true, isAM: isItAM(date: entry.date), colorGreen: entry.goalMet)
                                                    }
                                                    .font(.caption)
                                                    .padding([.bottom, .top], 5)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 14)
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

                Spacer(minLength: 28)
            }
        }
        .environment(store)
        .environment(goals)
    }
}

#Preview {
    HistoryYesterday()
        .environment(CommonStore())
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
