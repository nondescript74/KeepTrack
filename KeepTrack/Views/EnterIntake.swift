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
    @State private var isSaving: Bool = false
    @State private var showingTypePicker: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 10) {
                    Text("Log Intake")
                        .font(.title3.bold())
                        .foregroundStyle(Color.accentColor)
                    
                    HStack(spacing: 16) {
                        // Custom picker button that shows a sheet instead of context menu
                        Button {
                            showingTypePicker = true
                        } label: {
                            HStack {
                                Text(name)
                                    .foregroundStyle(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .fixedSize(horizontal: true, vertical: false)
                        .layoutPriority(1)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5)
                        )
                        .sheet(isPresented: $showingTypePicker) {
                            NavigationStack {
                                List(cIntakeTypes.sortedIntakeTypeNameArray, id: \.self) { typeName in
                                    Button {
                                        name = typeName
                                        showingTypePicker = false
                                    } label: {
                                        HStack {
                                            Text(typeName)
                                                .foregroundStyle(.primary)
                                            Spacer()
                                            if name == typeName {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(.blue)
                                            }
                                        }
                                    }
                                }
                                .navigationTitle("Select Type")
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Cancel") {
                                            showingTypePicker = false
                                        }
                                    }
                                }
                            }
                            .presentationDetents([.medium, .large])
                        }
                        Spacer()
                        
                        
                        
                        Button {
                            guard !isSaving else { return }
                            isSaving = true
                            
                            let goalToUse = goals.getTodaysGoalForName(namez: self.name)
                            if goalToUse == nil {
                                let entry = CommonEntry(id: UUID(), date: Date(), units: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: true)
                                Task { 
                                    await store.addEntry(entry: entry)
                                    try? await Task.sleep(for: .milliseconds(500))
                                    isSaving = false
                                }
                                logger.info("CommonStore: Added intake  \(name) no goals for name")
                                
                            } else {
                                logger.info("goalToUse dates are \(goalToUse!.dates.compactMap({$0}))")
                                let result = isGoalMet(goal: goalToUse!, previous: store.getTodaysIntake().filter({$0.name == self.name}).count)
                                logger.info("todays intake \(result)")
                                let entry = CommonEntry(id: UUID(), date: Date(), units: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: cIntakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: result)
                                Task { 
                                    await store.addEntry(entry: entry)
                                    try? await Task.sleep(for: .milliseconds(500))
                                    isSaving = false
                                }
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
                        .disabled(isSaving)
                        .opacity(isSaving ? 0.6 : 1.0)
                    }
                    Spacer()
                }
                .padding(.horizontal)
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
