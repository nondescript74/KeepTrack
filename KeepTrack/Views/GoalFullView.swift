//
//  GoalFullView.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/15/25.
//

import SwiftUI
import OSLog

struct GoalFullView: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "GoalFullView")
    
    @Environment(CommonGoals.self) var goals
    @EnvironmentObject var cIntakeTypes: CurrentIntakeTypes
    @Environment(\.dismiss) var dismiss
    
    var goal:CommonGoal
    
    @State fileprivate var dates: [Date]
    @State fileprivate var isActive: Bool
    @State fileprivate var isCompleted: Bool
    
    init(goal:CommonGoal) {
        self.goal = goal
        self.isActive = goal.isActive
        self.isCompleted = goal.isCompleted
        self.dates = goal.dates
    }
    
    fileprivate func getFormattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:MM a"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(goal.name)
                    .font(.title.bold())
                Text(goal.isActive ? "Active" : "Inactive")
                    .font(.caption)
                    .foregroundColor(goal.isActive ? .green : .secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)

            // Details Section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Dosage:").font(.subheadline)
                    Spacer()
                    Text("\(cIntakeTypes.intakeTypeArray.first(where: { $0.name == self.goal.name })?.amount ?? 0, specifier: "%.2f") ")
                        .bold()
                    Text(cIntakeTypes.intakeTypeArray.first(where: { $0.name == self.goal.name })?.unit ?? "unit")
                        .bold()
                }
                HStack {
                    Text("Frequency:").font(.subheadline)
                    Spacer()
                    Text(cIntakeTypes.intakeTypeArray.first(where: { $0.name == self.goal.name })?.frequency ?? frequency.none.rawValue)
                        .bold()
                }
                VStack(alignment: .leading) {
                    Text("Times:").font(.subheadline)
                    HStack {
                        ForEach(goal.dates, id: \.self) { adate in
                            Text(getFormattedDate(adate))
                                .font(.caption)
                                .padding(.trailing, 4)
                        }
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)

            // Edit Controls Section
            VStack(spacing: 12) {
                Toggle("Active", isOn: $isActive)
                Button("Save Changes") {
                    let savedUUID = self.goal.id
                    let goal = CommonGoal(
                        id: savedUUID,
                        name: self.goal.name,
                        description: cIntakeTypes.intakeTypeArray.first(where: { $0.name == self.goal.name })?.descrip ?? "no description",
                        dates: self.dates,
                        isActive: self.isActive,
                        isCompleted: self.isCompleted,
                        dosage: cIntakeTypes.intakeTypeArray.first(where: { $0.name == self.goal.name })?.amount ?? 0,
                        units: cIntakeTypes.intakeTypeArray.first(where: { $0.name == self.goal.name })?.unit ?? "no unit",
                        frequency: cIntakeTypes.intakeTypeArray.first(where: { $0.name == self.goal.name })?.frequency ?? frequency.none.rawValue
                    )
                    goals.addGoal(goal: goal)
                    logger.info("added new goal")
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)
            Spacer()
        }
        .padding()
        .environment(goals)
    }
}

#Preview {
    let goal = CommonGoal(id: UUID(), name: "Metformin ER", description: "Sugar control", dates: [Date()], isActive: true, isCompleted: false, dosage: 400, units: "mg", frequency: frequency.twiceADay.rawValue)
    GoalFullView(goal: goal)
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
