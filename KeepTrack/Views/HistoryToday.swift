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
        logger.info("gT\(myReturn.count)")
        return myReturn
    }
    
    fileprivate func sortTodayByName(name: String) -> [CommonEntry] {
        let myReturn  = getToday().filter { $0.name.lowercased() == name.lowercased() }.sorted { $0.date < $1.date }
        logger.info("sTBN \(myReturn.count)")
        return myReturn
    }
    
    fileprivate func getUniqueTodaysCommonEntriesUntilNow(name: String) -> [CommonEntry] {
        let myReturn: [CommonEntry] = sortTodayByName(name: name)
        logger.info("gUTCEUN \(myReturn.debugDescription)")
        return myReturn
    }
    
    func getTypeColor(intakeType: IntakeType) -> Color {
        let types = cIntakeTypes.sortedIntakeTypeArray
        let index = types.firstIndex(of: intakeType)!
        return colors[index]
    }
    
    func getHour(from date: Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = .current
        let hour = calendar.component(.hour, from: date)
        return hour
    }
    
    func getMinute(from date: Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = .current
        let minute = calendar.component(.minute, from: date)
        return minute
    }
    
    var body: some View {
        VStack  {
            Text("Today")
                .font(.title)
//            Text("Types count: \(cIntakeTypes.sortedIntakeTypeArray.count)")
            if getToday().isEmpty {
                Text("Nothing taken today")
                    .foregroundColor(.red)
            }
            VStack {
                ScrollView {
                    ForEach(cIntakeTypes.sortedIntakeTypeArray, id: \.self) { type in
//                        Text("Type: \(type.name), Entries today: \(sortTodayByName(name: type.name).count)")
                        if !sortTodayByName(name: type.name).isEmpty {
                            HStack {
                                Text("\(type.name): ")
                                    .foregroundStyle(getTypeColor(intakeType: type))
                                    .font(.subheadline)
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(getUniqueTodaysCommonEntriesUntilNow(name: type.name)) { entry in
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
                Divider()
                EnterIntake()
                Divider()
            }
            
        }
        .environment(store)
        .environment(goals)
    }
    
}

#Preview {
    HistoryToday()
        .environment(CommonStore())
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
