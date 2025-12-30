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
    @State private var customAmount: Double?
    @State private var hasEditedAmount: Bool = false
    @FocusState private var amountFieldIsFocused: Bool
    
    // Get the default amount from the selected intake type
    private var defaultAmount: Double {
        cIntakeTypes.intakeTypeArray.first(where: { $0.name == name })?.amount ?? 0
    }
    
    // Use custom amount if set, otherwise use default
    private var currentAmount: Double {
        customAmount ?? defaultAmount
    }
    
    // Get the unit for the selected intake type
    private var currentUnit: String {
        cIntakeTypes.intakeTypeArray.first(where: { $0.name == name })?.unit ?? "no unit"
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                Text("Log Intake")
                    .font(.title3.bold())
                    .foregroundStyle(Color.accentColor)
                    .padding(.top, 4)
                    
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
                                        // Reset custom amount when changing intake type
                                        customAmount = nil
                                        hasEditedAmount = false
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
                                    ToolbarItem(placement: .primaryAction) {
                                        Button {
                                            Task {
                                                await cIntakeTypes.reloadFromBundle()
                                            }
                                        } label: {
                                            Image(systemName: "arrow.clockwise")
                                        }
                                    }
                                }
                            }
                            .presentationDetents([.medium, .large])
                        }
                        
                        Spacer()
                    }
                    
                    // Amount field with unit display
                    HStack(spacing: 12) {
                        Text("Amount ")
                            .font(.default)
                            .foregroundStyle(.secondary)
                        
                        TextField("Amount", value: Binding(
                            get: { currentAmount },
                            set: { newValue in
                                customAmount = newValue
                                hasEditedAmount = true
                            }
                        ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .focused($amountFieldIsFocused)
                        .onTapGesture {
                            if !hasEditedAmount {
                                // Clear the field on first tap
                                customAmount = 0
                                hasEditedAmount = true
                            }
                        }
                        .frame(width: 40)
                        
                        Text(currentUnit)
                            .font(.default)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        
                        
                        Button {
                            guard !isSaving else { return }
                            isSaving = true
                            
                            let goalToUse = goals.getTodaysGoalForName(namez: self.name)
                            if goalToUse == nil {
                                let entry = CommonEntry(id: UUID(), date: Date(), units: currentUnit, amount: currentAmount, name: name, goalMet: true)
                                Task { 
                                    await store.addEntry(entry: entry)
                                    try? await Task.sleep(for: .milliseconds(500))
                                    isSaving = false
                                    // Reset fields after successful save
                                    customAmount = nil
                                    hasEditedAmount = false
                                }
                                logger.info("CommonStore: Added intake  \(name) no goals for name")
                                
                            } else {
                                logger.info("goalToUse dates are \(goalToUse!.dates.compactMap({$0}))")
                                let result = isGoalMet(goal: goalToUse!, previous: store.getTodaysIntake().filter({$0.name == self.name}).count)
                                logger.info("todays intake \(result)")
                                let entry = CommonEntry(id: UUID(), date: Date(), units: currentUnit, amount: currentAmount, name: name, goalMet: result)
                                Task { 
                                    await store.addEntry(entry: entry)
                                    try? await Task.sleep(for: .milliseconds(500))
                                    isSaving = false
                                    // Reset fields after successful save
                                    customAmount = nil
                                    hasEditedAmount = false
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
                    .padding(.horizontal)
                    
                    // Remove the Spacer() that was pushing content down
                }
                .padding(.horizontal)
        }
        .environment(store)
        .environment(goals)
        // NOTE: Removed automatic reloadFromBundle() to preserve user-added intake types
        // .task {
        //     // Reload from bundle every time this view appears to pick up any JSON changes
        //     await cIntakeTypes.reloadFromBundle()
        // }
    }
}

#Preview {
    EnterIntake()
        .environment(CommonStore())
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
