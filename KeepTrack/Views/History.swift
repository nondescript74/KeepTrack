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
    @Environment(CurrentIntakeTypes.self) private var cIntakeTypes
    
    @State private var toggeled: Bool = false
    
    let rowLayout = Array(repeating: GridItem(.flexible(minimum: 10)), count: 3)
    
    fileprivate var zBug: Bool = false
    
    fileprivate func getToday() -> [CommonEntry] {
        let myReturn = store.history.filter { Calendar.current.isDateInToday($0.date) }
        if zBug {logger.info("gT\(myReturn.count)") }
        return myReturn
    }
    
    
    fileprivate func getYesterday() -> [CommonEntry] {
        let myReturn = store.history.filter { Calendar.current.isDateInYesterday($0.date) }
        if zBug {logger.info("gY \(myReturn.count)") }
        return myReturn
    }
    //
    
    fileprivate func sortTodayByName(name: String) -> [CommonEntry] {
        let myReturn  = getToday().filter { $0.name.lowercased() == name.lowercased() }.sorted { $0.date < $1.date }
        if zBug {logger.info("sTBN \(myReturn.count)") }
        return myReturn
    }
    
    fileprivate func sortYesterdayByName(name: String) -> [CommonEntry] {
        let myReturn = getYesterday().filter { $0.name.lowercased() == name.lowercased() }.sorted { $0.date < $1.date }.uniqued()
        if zBug {logger.info("sYBN \(myReturn.count)") }
        return myReturn
    }
    //
    
    fileprivate func getUniqueTodayByNameCount(name: String) -> Int {
        let myReturn: Int = sortTodayByName(name: name).count
        if zBug {logger.info("gUTBNCount: \(myReturn)") }
        return myReturn
    }
    
    fileprivate func getUniqueYesterdayByNameCount(name: String) -> Int {
        let myReturn: Int = sortYesterdayByName(name: name).count
        if zBug {logger.info("gUYBNCount: \(myReturn)") }
        return myReturn
    }
    //
    
    
    fileprivate func getTodaysGoalsByNameCount(name: String) -> Int {
        let myReturn: Int = goals.goals.filter { $0.name.lowercased() == name.lowercased() }.count
        if zBug {logger.info("gYGBNC: \(myReturn)") }
        return myReturn
    }
    
    fileprivate func getYesterdaysGoalsByNameCount(name: String) -> Int {
        let myReturn: Int = goals.goals.filter { $0.name.lowercased() == name.lowercased() }.count
        if zBug {logger.info("gYGBNC: \(myReturn)") }
        return myReturn
    }
    //
    
    fileprivate func getUniqueTodaysCommonEntriesUntilNow(name: String) -> [CommonEntry] {
        let myReturn: [CommonEntry] = sortTodayByName(name: name)
        if zBug {logger.info("gUTCEUN \(myReturn.debugDescription)") }
        return myReturn
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
    
    func getTypeColor(intakeType: IntakeType) -> Color {
        let types = cIntakeTypes.intakeTypeArray.sorted(by: {$0.name < $1.name})
        let index = types.firstIndex(of: intakeType)!
        return colors[index]
    }
    
    var body: some View {
        VStack  {
            Text("Today")
                .font(.title)
            if getToday().isEmpty {
                Text("Nothing taken today")
                    .foregroundColor(.red)
            } else {
                
                ForEach(cIntakeTypes.intakeTypeArray.sorted(by: {$0.name < $1.name}), id: \.self) { type in
                    if !sortTodayByName(name: type.name).isEmpty {
                        HStack {
                            Text("\(type.name): ")
                                .foregroundStyle(getTypeColor(intakeType: type))
                                .font(.subheadline)
                            
                            Spacer()
                            
                            ForEach(getUniqueTodaysCommonEntriesUntilNow(name: type.name)) { entry in
                                    Clock(hour: getHour(from: entry.date), minute: getMinute(from: entry.date), is12HourFormat: true, isAM: isItAM(date: entry.date), colorGreen: entry.goalMet)
                            }
                        }
                        .font(.caption)
                        .padding(.trailing)
                    }
                }
            }
        }
        .padding(.horizontal)
        
        Divider()
        
        VStack {
            Text("Yesterday")
                .font(.title)
            if getYesterday().isEmpty {
                Text("Nothing taken yesterday")
                    .foregroundColor(.red)
            } else {
                ForEach(cIntakeTypes.intakeTypeArray.sorted(by: {$0.name < $1.name}), id: \.self) { type in
                    if !sortYesterdayByName(name: type.name).isEmpty {
                        HStack {
                            Text("\(type.name): ")
                                .foregroundStyle(getTypeColor(intakeType: type))
                            Spacer()
                            Text(getUniqueYesterdayByNameCount(name: type.name).description)
                            
                        }
                        .font(.caption)
                        .padding(.trailing)
                        
                    }
                }
            }
        }
        .padding(.horizontal)
        .environment(store)
        .environment(goals)
        .environment(cIntakeTypes)
#if os(VisionOs)
        .glassBackgroundEffect()
#endif
    }
}

#Preview {
    History()
        .environment(CommonStore())
        .environment(CommonGoals())
        .environment(CurrentIntakeTypes())
}

