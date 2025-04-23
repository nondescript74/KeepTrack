//
//  EnterIntake.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog

struct EnterIntake: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterIntake")
    @Environment(CommonStore.self) var store
    @Environment(CommonGoals.self) var goals
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = types.sorted(by: {$0 < $1})[6]
    
    fileprivate func isGoalMet() -> Bool {
        
        // get the goals, if any, by this time
        // for each intake, if its being taken before the goal(there may be several), then its a intake taken as goal met.
        // another way of looking at this is if the number of instances of that intake type + 1 is equal to or greater than the goal instances, then it is goal met
        
        var result: Bool = false
        let goalsForName = goals.getTodaysGoalsForName(namez: name)
        
        if goalsForName.isEmpty { return true }
        
        let currentDateTime = Date()
        let componentsNow = Calendar.current.dateComponents([.hour,.minute], from: currentDateTime)
        let hourNow = componentsNow.hour
        let minuteNow = componentsNow.minute
        
        if goalsForName.count > 1 { logger.warning("More than one goal for \(name), using first one") }
        if store.getTodaysIntake().count + 1 > goalsForName.count {
            // counting this one as one
            return true
        } else if store.getTodaysIntake().count + 1 == goalsForName.count {
            let lastGoal = goalsForName.sorted(by: {$0.dates[0] < $1.dates[0]}).last
            let componentsLastGoal = Calendar.current.dateComponents([.hour,.minute], from: lastGoal!.dates[0])
            
            if hourNow! <= componentsLastGoal.hour! && minuteNow! <= componentsLastGoal.minute! {
                result = true
            } else if hourNow! <= componentsLastGoal.hour! && minuteNow! < componentsLastGoal.minute! {
                result = true
            } else {
                result = false
            }
        } else {
            result = false
        }
        return result
    }
    
    fileprivate func getMatchingUnit() -> String {
        return matchingUnitsDictionary.first(where: {$0.key == name})?.value ?? ""
    }
    
    fileprivate func getMatchingAmount() -> Double {
        return matchingAmountDictionary.first(where: {$0.key == name})?.value ?? 0
    }
    
    var body: some View {
        VStack {
            Text("Enter intake details")
                .font(.headline)
                .fontWeight(.bold)
            HStack {
                Text("item")
                Picker("Select Type", selection: $name) {
                    ForEach(types.sorted(by: {$0 < $1}), id: \.self) {
                        Text($0)
                    }
                }
            }
            HStack {
                Text("amount")
                Text(getMatchingAmount().formatted())
                Text(getMatchingUnit())
            }
            .padding(.bottom)
            Button("Add") {
                
                let entry = CommonEntry(id: UUID(), date: Date(), units: getMatchingUnit(), amount: getMatchingAmount(), name: name, goalMet: isGoalMet())
                
                store.addEntry(entry: entry)
                
                logger.info("Added intake  \(name) \(getMatchingAmount()) units \(getMatchingUnit())")
                
                
                dismiss()
            }.disabled(name.isEmpty)
            Spacer()
            
        }
        .environment(store)
        .environment(goals)
    }
}

#Preview {
    EnterIntake()
        .environment(CommonStore())
        .environment(CommonGoals())
}
