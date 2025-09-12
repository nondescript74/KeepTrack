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
    @EnvironmentObject var cIntakeTypes: CurrentIntakeTypes
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
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .background(
                        LinearGradient(
                            colors: [.accentColor.opacity(0.2), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(10)
                
                VStack(spacing: 10) {
                    Text("Log Intake")
                        .font(.title3.bold())
                        .foregroundStyle(Color.accentColor)
//                        .padding(.bottom, 6)
                    
                    HStack(spacing: 16) {
                        Picker("Select Type", selection: $name) {
                            ForEach(cIntakeTypes.sortedIntakeTypeNameArray, id: \.self) {
                                Text($0)
                                    .padding(.horizontal, 10)
                            }
                        }
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5)
                        )
                        .padding(.trailing)
                        
                        Spacer()
                        
                        Button {
                            let goalToUse = goals.getTodaysGoalForName(namez: self.name)
                            if goalToUse == nil {
                                let entry = CommonEntry(id: UUID(), date: Date(), units: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: true)
                                Task { await store.addEntry(entry: entry) }
                                logger.info("CommonStore: Added intake  \(name) no goals for name")
                                
                            } else {
                                logger.info("goalToUse dates are \(goalToUse!.dates.compactMap({$0}))")
                                let result = isGoalMet(goal: goalToUse!, previous: store.getTodaysIntake().filter({$0.name == self.name}).count)
                                logger.info("todays intake \(result)")
                                let entry = CommonEntry(id: UUID(), date: Date(), units: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: result)
                                Task { await store.addEntry(entry: entry) }
                                logger.info("CommonStore: added intake \(name)")
                            }
                        } label: {
                            Image(systemName: "plus.arrow.trianglehead.clockwise")
                                .font(.title3)
                                .padding(10)
                                .background(.blue.gradient, in: Capsule())
                                .foregroundColor(.white)
                                .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 3)
                        }
                    }
                    Spacer()
                }
                .padding(16)
            }
            .environment(store)
            .environment(goals)
        }
    }
}

#Preview {
    EnterIntake()
        .environment(CommonStore())
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
