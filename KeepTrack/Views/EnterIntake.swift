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
    @Environment(CurrentIntakeTypes.self) var cIntakeTypes
//    @Environment(HealthKitManager.self) var healthKitManager
    @Environment(\.dismiss) var dismiss
    
    let dateFormatter = DateFormatter()
    
    var dataTypeIdentifier: String
    var dataValues: [HealthDataTypeValue] = []
    
    public var showGroupedTableViewTitle: Bool = false
    
    // MARK: Initializers
    
    init() {
        self.dataTypeIdentifier = "Water"
    }
    
    @State private var name: String = "Water"
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Enter intake details")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Picker("Select Type", selection: $name) {
                    ForEach(cIntakeTypes.intakeTypeNameArray.sorted(by: {$0 < $1}), id: \.self) {
                        Text($0)
                    }
                }
//                .background(Color.gray.opacity(1.0))
                
                HStack {
                    Text("amount")
                    Text(cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount.description ?? 0.description)
                    Text(cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit")
                }
                .padding(.bottom)
                
                
                
                Button(action: ( {
                    let goalToUse = goals.getTodaysGoalForName(namez: self.name)
                    // single goal
                    
                    if goalToUse == nil {
                        let entry = CommonEntry(id: UUID(), date: Date(), units: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: true)
                        store.addEntry(entry: entry)
                        logger.info("CommonStore: Added intake  \(name) no goals for name")
//                        if name == "Water" && healthKitManager.descriptionLabel.contains("authorized") {
//                            Task {
//                                await healthKitManager.addWaterSample(quantity:  HKQuantity(unit: HKUnit.fluidOunceUS(), doubleValue: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount ?? 0))
//                            }
//                        }
                    } else {
                        logger.info("goalToUse dates are \(goalToUse!.dates.compactMap({$0}))")
                        let result = isGoalMet(goal: goalToUse!, previous: store.getTodaysIntake().filter({$0.name == self.name}).count)
                        logger.info("todays intake \(result)")
                        let entry = CommonEntry(id: UUID(), date: Date(), units: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: result)
                        store.addEntry(entry: entry)
                        logger.info("CommonStore: added intake \(name)")
//                        if name == "Water" && healthKitManager.descriptionLabel.contains("authorized") {
//                            Task {
//                                await healthKitManager.addWaterSample(quantity:  HKQuantity(unit: HKUnit.fluidOunceUS(), doubleValue: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount ?? 0))
//                            }
//                        } else if name == "Water" && !healthKitManager.descriptionLabel.contains("authorized") {
//                            logger.warning("EnterIntake: cannot add water sample via HealthKit, not authorized")
//                        }
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
            .environment(cIntakeTypes)
//            .environment(healthKitManager)
        }
    }
}

#Preview {
    EnterIntake()
        .environment(CommonStore())
        .environment(CommonGoals())
        .environment(CurrentIntakeTypes())
//        .environment(HealthKitManager())
}
