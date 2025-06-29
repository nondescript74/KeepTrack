//
//  EnterIntake.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog
import HealthKit

struct EnterIntake: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterIntake")
    @Environment(CommonStore.self) var store
    @Environment(CommonGoals.self) var goals
    @Environment(HealthKitManager.self) var healthKitManager
    @Environment(\.dismiss) var dismiss
    
    let dateFormatter = DateFormatter()
    
    var dataTypeIdentifier: String
    var dataValues: [HealthDataTypeValue] = []
    
    public var showGroupedTableViewTitle: Bool = false
    
    // MARK: Initializers
    
    init() {
        self.dataTypeIdentifier = "Water"
    }
    
    @State private var name: String = (types.sorted(by: {$0 < $1}).last ?? types.sorted(by: {$0 < $1})[0])
    
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
            
            Picker("Select Type", selection: $name) {
                ForEach(types.sorted(by: {$0 < $1}), id: \.self) {
                    Text($0)
                }
            }
            .background(Color.gray.opacity(1.0))
            
            HStack {
                Text("amount")
                Text(getMatchingAmount().formatted())
                Text(getMatchingUnit())
            }
            .padding(.bottom)
            
            
            
            Button(action: ( {
                let goalToUse = goals.getTodaysGoalForName(namez: self.name)
                // single goal
                
                if goalToUse == nil {
                    let entry = CommonEntry(id: UUID(), date: Date(), units: getMatchingUnit(), amount: getMatchingAmount(), name: name, goalMet: true)
                    store.addEntry(entry: entry)
                    logger.info("CommonStore: Added intake  \(name) no goals for name")
                    if name == "Water" && healthKitManager.descriptionLabel.contains("authorized") {
                        Task {
                            await healthKitManager.addWaterSample(quantity:  HKQuantity(unit: HKUnit.fluidOunceUS(), doubleValue: getMatchingAmount()))
                        }
                    }
                } else {
                    logger.info("goalToUse dates are \(goalToUse!.dates.compactMap({$0}))")
                    let result = isGoalMet(goal: goalToUse!, previous: store.getTodaysIntake().filter({$0.name == self.name}).count)
                    logger.info("todays intake \(result)")
                    let entry = CommonEntry(id: UUID(), date: Date(), units: getMatchingUnit(), amount: getMatchingAmount(), name: self.name, goalMet: result)
                    store.addEntry(entry: entry)
                    logger.info("CommonStore: added intake \(name)")
                    if name == "Water" && healthKitManager.descriptionLabel.contains("authorized") {
                        Task {
                            await healthKitManager.addWaterSample(quantity:  HKQuantity(unit: HKUnit.fluidOunceUS(), doubleValue: getMatchingAmount()))
                        }
                    } else if name == "Water" && !healthKitManager.descriptionLabel.contains("authorized") {
                        logger.warning("EnterIntake: cannot add water sample via HealthKit, not authorized")
                    }
                }
            }), label: ({
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
            }))
            .padding()
            .foregroundStyle(.blue)
            Spacer()
        }
        .environment(store)
        .environment(goals)
        .environment(healthKitManager)
    }
}

#Preview {
    EnterIntake()
        .environment(CommonStore())
        .environment(CommonGoals())
        .environment(HealthKitManager())
}
