//
//  EnterGoal.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog

struct EnterGoal: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterGoal")
    
    @Environment(CommonGoals.self) var goals
    @EnvironmentObject var cIntakeTypes: CurrentIntakeTypes
    @Environment(\.dismiss) var dismiss
    
    @State fileprivate var name: String = "Water"
    @State fileprivate var startDate: Date = Date()
    @State private var showingTypePicker: Bool = false
#if os(iOS)
    @State fileprivate var stateFul: Bool = true
#endif
#if os(macOS) || os(iPadOS)
    @State fileprivate var stateFul: Bool = false
#endif
#if os(visionOS)
    @State fileprivate var stateFul: Bool = false
#endif
    
    
    fileprivate func getMatchingDesription() -> String {
        let myReturn = cIntakeTypes.intakeTypeArray.first(where: { $0.name == name })?.descrip ?? "no description"
        logger.info("\(myReturn)")
        return myReturn
    }
    
    fileprivate func getMatchingUnits() -> String {
        let myReturn = cIntakeTypes.intakeTypeArray.first(where: { $0.name == name })?.unit ?? units.none.rawValue
        logger.info("\(myReturn)")
        return myReturn
    }
    
    fileprivate func getMatchingAmounts() -> Double {
        return cIntakeTypes.intakeTypeArray.first(where: { $0.name == name })?.amount ?? 0
    }
    
    fileprivate func getMatchingFrequency() -> frequency.RawValue {
        let myReturn = cIntakeTypes.intakeTypeArray.first(where: { $0.name == name })?.frequency ?? frequency.none.rawValue
        logger.info("\(myReturn)")
        return myReturn
    }
    
    
    var body: some View {
        VStack {
            // Header
            VStack(alignment: .leading) {
                Text("Enter Goal")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.blue)
                Text("Create or update your goals below.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial)
            .cornerRadius(12)

            // Intake Picker and Description
            VStack(alignment: .leading) {
                HStack {
                    Text("Select intake:")
                    Spacer()
                    // Custom picker button that shows a sheet instead of menu
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
                        GoalTypePickerSheet(
                            selectedName: $name,
                            isPresented: $showingTypePicker
                        )
                        .environmentObject(cIntakeTypes)
                    }
                }
                Text(getMatchingDesription())
                    .font(.caption)
                    .foregroundStyle(.purple)
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)

            // Dosage/Units/Frequency
            VStack(alignment: .leading) {
                HStack {
                    Text("Dosage:").font(.subheadline)
                    Spacer()
                    Text("\(getMatchingAmounts(), specifier: "%.2f")")
                        .bold()
                    Text(getMatchingUnits()).bold()
                }
                HStack {
                    Text("Frequency:").font(.subheadline)
                    Spacer()
                    Text(getMatchingFrequency()).bold()
                }
            }
            .background(.ultraThinMaterial)
            .cornerRadius(12)

            // Date Picker & Add Button (changed to HStack with compact button)
            VStack(alignment: .leading, spacing: 8) {
                Text("First dose time")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack {
                    DatePicker(
                        "Start Time",
                        selection: $startDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    Button(action: ({
                        if self.name.isEmpty {
                            return
                        }
                        if goals.goals.contains(where: { $0.name == self.name }) {
                            let remain = goals.goals.filter( { $0.name == self.name } )
                            if remain.count > 1 {
                                fatalError( "Too many goals with same name: \(self.name)" )
                            }
                            var newDates = remain[0].dates
                            newDates.append(startDate)
                            let goal = CommonGoal(id: remain[0].id, name: name, description: getMatchingDesription(), dates: newDates, isActive: true, isCompleted: false, dosage: getMatchingAmounts(), units: getMatchingUnits(), frequency: getMatchingFrequency() )

                            goals.addGoal(goal: goal)
                        } else {
                            let dateArrayForGoal: [Date] = matchingDateArray(name: self.name, startDate: startDate)

                            logger.info( "name: \(self.name)" )
                            logger.info( "dateArrayForGoal: \(dateArrayForGoal)" )
                            let goal = CommonGoal(id: UUID(), name: self.name, description: getMatchingDesription(), dates: dateArrayForGoal, isActive: true, isCompleted: false, dosage: getMatchingAmounts(), units: getMatchingUnits(), frequency: getMatchingFrequency() )
                            goals.addGoal(goal: goal)
                            logger.info("added a new goal")
                        }
                        self.name = cIntakeTypes.intakeTypeArray.sorted(by: {$0.name < $1.name})[0].name
                    }), label: ({
                        Image(systemName: "plus.arrow.trianglehead.clockwise")
                            .padding(7)
                            .background(Color.blue.gradient, in: Capsule())
                            .foregroundColor(.white)
                    }))
                    .buttonStyle(.bordered)
                }
                Text("Other doses will be scheduled automatically based on frequency")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)

            // Current Goals List
            VStack(alignment: .leading, spacing: 6) {
                Text("Current Goals:")
                    .font(.headline)
                    .foregroundStyle(Color.green)
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(goals.goals, id: \.id) { goal in
                            Text(goal.name)
                                .font(.body.bold())
                                .foregroundStyle(.primary)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.07)))
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .environment(goals)
        .environmentObject(cIntakeTypes)
    }
}

// MARK: - Type Picker Sheet for Goals
private struct GoalTypePickerSheet: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "GoalTypePickerSheet")
    @EnvironmentObject var cIntakeTypes: CurrentIntakeTypes
    @Binding var selectedName: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Group {
                if cIntakeTypes.sortedIntakeTypeNameArray.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Loading intake types...")
                            .foregroundStyle(.secondary)
                        Button("Reload") {
                            Task {
                                await cIntakeTypes.reloadFromBundle()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(cIntakeTypes.sortedIntakeTypeNameArray, id: \.self) { typeName in
                        Button {
                            logger.info("Selected type: \(typeName)")
                            selectedName = typeName
                            isPresented = false
                        } label: {
                            HStack {
                                Text(typeName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedName == typeName {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Intake Type")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        logger.info("Reload button tapped")
                        Task {
                            await cIntakeTypes.reloadFromBundle()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 500)
        #else
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        #endif
        .onAppear {
            logger.info("GoalTypePickerSheet appeared with \(cIntakeTypes.sortedIntakeTypeNameArray.count) types")
            logger.info("Types: \(cIntakeTypes.sortedIntakeTypeNameArray.joined(separator: ", "))")
        }
    }
}

#Preview {
    EnterGoal()
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
