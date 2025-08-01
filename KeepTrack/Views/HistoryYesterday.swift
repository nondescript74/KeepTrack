//
//  HistoryYesterday.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/30/25.
//

import SwiftUI
import OSLog

struct HistoryYesterday: View {
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "History")
    @Environment(CommonStore.self) private var store
    @Environment(CommonGoals.self) private var goals
    @Environment(CurrentIntakeTypes.self) private var cIntakeTypes
    
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
        let types = cIntakeTypes.intakeTypeArray.sorted(by: {$0.name < $1.name})
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
    }
}

#Preview {
    HistoryYesterday()
}
