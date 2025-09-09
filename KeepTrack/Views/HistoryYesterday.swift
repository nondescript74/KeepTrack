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
        VStack {
            Text("Yesterday")
                .font(.title)
            
            Text(getYesterday().isEmpty ? "No entries yet" : "")
                .foregroundColor(.red)
            
            ScrollView {
                ForEach(cIntakeTypes.sortedIntakeTypeArray, id: \.self) { type in
                    if !sortYesterdayByName(name: type.name).isEmpty {
                        HStack {
                            Text("\(type.name): ")
                                .foregroundStyle(getTypeColor(intakeType: type))
                                .font(.subheadline)
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(sortYesterdayByName(name: type.name), id: \.self) { entry in
                                        Clock(hour: getHour(from: entry.date), minute: getMinute(from: entry.date), is12HourFormat: true, isAM: isItAM(date: entry.date), colorGreen: entry.goalMet)
                                    }
                                    .font(.caption)
                                    .padding([.bottom, .top], 5)
                                }
                            }
                            
                        }
                    }
                }
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
}

