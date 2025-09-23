//
//  ShowAndEditGoals.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog

struct EditGoals: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditGoals")
    @Binding var items: [CommonGoal]
    @Environment(CommonGoals.self) var goals
    @EnvironmentObject var cIntakeTypes: CurrentIntakeTypes
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Goals")
                    .font(.title2.bold())
                    .foregroundColor(.accentColor)
                
                MovableGoalList(self.$items) { item in
                    HStack {
                        if item.isCompleted.wrappedValue {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else if item.isActive.wrappedValue {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                        
                        let dosageString = String(format: "%.0f %@", item.dosage.wrappedValue, item.units.wrappedValue)
                        VStack(alignment: .leading) {
                            Text(item.name.wrappedValue)
                                .fontWeight(.semibold)
                            Text(item.description.wrappedValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(dosageString)
                                .font(.caption2)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.08))
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                .animation(.default, value: items)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
        .environment(goals)

    }
    
}

#Preview {
    @Previewable @State var items: [CommonGoal] =
    [CommonGoal(id: UUID(), name: "Losartan", description: "Blood pressure", dates: [Date()], isActive: true, isCompleted: false, dosage: 25.0, units: "mg", frequency: frequency.daily.rawValue),
     CommonGoal(id: UUID(), name: "Metformin", description: "Sugar control", dates: [Date(), Date().addingTimeInterval(60 * 60 * 2)], isActive: true, isCompleted: false, dosage: 400, units: "mgs", frequency: frequency.twiceADay.rawValue)]
    
    EditGoals(items: $items)
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}

