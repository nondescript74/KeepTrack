//
//  History.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog
import HealthKit

struct History: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "History")
    @Environment(CommonStore.self) private var store
    @Environment(CommonGoals.self) private var goals
    
    let rowLayout = Array(repeating: GridItem(.flexible(minimum: 10)), count: 3)
    
    fileprivate func getToday() -> [CommonEntry] {
        let myReturn = store.history.filter { Calendar.current.isDateInToday($0.date) }
//        logger.info("gT\(myReturn.count)")
        return myReturn
    }
    
    
    fileprivate func getYesterday() -> [CommonEntry] {
        let myReturn = store.history.filter { Calendar.current.isDateInYesterday($0.date) }
//        logger.info("gY \(myReturn.count)")
        return myReturn
    }
    
    fileprivate func sortTodayByName(name: String) -> [CommonEntry] {
        let myReturn  = getToday().filter { $0.name.lowercased() == name.lowercased() }.sorted { $0.date < $1.date }
//        logger.info("sTBN \(myReturn.count)")
        return myReturn
    }
    
    
    fileprivate func sortYesterdayByName(name: String) -> [CommonEntry] {
        let myReturn = getYesterday().filter { $0.name.lowercased() == name.lowercased() }.sorted { $0.date < $1.date }.uniqued()
//        logger.info("sYBN \(myReturn.count)")
        return myReturn
    }
    
    fileprivate func getUniqueYesterdayByNameCount(name: String) -> Int {
        let myReturn: Int = sortYesterdayByName(name: name).count
        logger.info("gYUBNC: \(myReturn)")
        return myReturn
    }
    
    fileprivate func getYesterdaysGoalsByNameCount(name: String) -> Int {
        let myReturn: Int = goals.goals.filter { $0.name.lowercased() == name.lowercased() }.count
        logger.info("gYGBNC: \(myReturn)")
        return myReturn
    }
    
    var body: some View {
        VStack {
            Text("Intake History")
                .font(.headline)
            
            List {
                Section(header: Text("Today")) {
                    VStack(alignment: .leading) {
                        if getToday().isEmpty {
                            Text("Nothing taken today")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(types, id: \.self) { type in
                                if sortTodayByName(name: type).isEmpty {
                                    Text("No \(type) ")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(sortTodayByName(name: type)) { entry in
                                                HStack {
                                                    Text(entry.date, style: .time)
                                                    Text(entry.name)
                                                }
                                                .font(.caption2)
                                                .foregroundStyle(entry.goalMet ? .green : .red)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Yesterday")) {
                    VStack(alignment: .leading) {
                        if getYesterday().isEmpty {
                            Text("Nothing taken yesterday")
                                .foregroundColor(.red)
                        } else {
                            ForEach(types, id: \.self) { type in
                                if sortYesterdayByName(name: type).isEmpty {
                                    Text("No \(type) ")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                } else {
                                    HStack {
                                        Text("\(type): ")
                                        Text(getUniqueYesterdayByNameCount(name: type).description)
                                    }
                                    .font(.caption)
                                    .foregroundStyle(getYesterdaysGoalsByNameCount(name: type) <= getUniqueYesterdayByNameCount(name: type) ? .green : .red)

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
    History()
        .environment(CommonStore())
        .environment(CommonGoals())
}

