//
//  History.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog

struct History: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "History")
    @Environment(CommonStore.self) private var store
    @Environment(CommonGoals.self) private var goals
    
    let rowLayout = Array(repeating: GridItem(.flexible(minimum: 10)), count: 3)
    
    fileprivate func getToday() -> [CommonEntry] {
        let myReturn = store.history.filter { Calendar.current.isDateInToday($0.date) }
        logger.info("\(myReturn)")
        return myReturn
    }
    
    fileprivate func getYesterday() -> [CommonEntry] {
        let myReturn = store.history.filter { Calendar.current.isDateInYesterday($0.date) }
        logger.info("\(myReturn)")
        return myReturn
    }
    
    fileprivate func sortTodayByName(name: String) -> [CommonEntry] {
        let myReturn = getToday().filter { $0.name.lowercased() == name.lowercased() }.sorted { $0.date < $1.date }
        logger.info("\(myReturn)")
        return myReturn
    }
    
    fileprivate func sortYesterdayByName(name: String) -> [CommonEntry] {
        let myReturn = getYesterday().filter { $0.name.lowercased() == name.lowercased() }.sorted { $0.date < $1.date }
        logger.info("\(myReturn)")
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
                                    Text("no \(type) taken")
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
                                    Text("no \(type) taken")
                                } else {
                                    HStack {
                                        ForEach(sortYesterdayByName(name: type)) { entry in
                                            HStack {
                                                Text(entry.name)
                                                Text(sortYesterdayByName(name: type).count.description)
                                            }
                                            .font(.caption)
                                        }
                                    }
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

