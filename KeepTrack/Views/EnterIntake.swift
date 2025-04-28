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
    
    @State var name: String = (types.sorted(by: {$0 < $1}).last ?? types.sorted(by: {$0 < $1})[0])
    
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
                let goalToUse = goals.getTodaysGoalForName(namez: self.name)
                
                if goalToUse == nil {
                    let entry = CommonEntry(id: UUID(), date: Date(), units: getMatchingUnit(), amount: getMatchingAmount(), name: name, goalMet: true)
                    
                    store.addEntry(entry: entry)
                    
                    logger.info("Added intake  \(name) no goals for name")
                } else {
                    let result = isGoalMet(goal: goalToUse!)
                    let entry = CommonEntry(id: UUID(), date: Date(), units: getMatchingUnit(), amount: getMatchingAmount(), name: name, goalMet: result)
                    store.addEntry(entry: entry)
                    logger.info(" goal met \(result)) added intake \(name) \(getMatchingAmount()) units \(getMatchingUnit())")
                }
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
