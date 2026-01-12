//
//  ChangeHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/11/25.
//

import SwiftUI
import OSLog

struct ChangeHistory: View {
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ChangeHistory")
    @Environment(CommonStore.self) private var store
    @Environment(CommonGoals.self) private var goals
    @EnvironmentObject private var intakeTypes: CurrentIntakeTypes
    
    @State private var selectedIntakeType: IntakeType?
    @State private var selectedDate: Date = Date()
    @State private var name: String = "Water"
    
    var body: some View {
        VStack {
            Text("Add History")
                .font(.title).bold()
                .foregroundStyle(Color.blue)
                .shadow(color: .blue.opacity(0.18), radius: 4, x: 0, y: 2)
                .padding(.top)
            
            VStack(spacing: 8) {
                HStack {
                    Picker("Select Type", selection: $name) {
                        ForEach(intakeTypes.sortedIntakeTypeNameArray, id: \.self) {
                            Text($0).font(.caption)
                        }
                    }
                    .font(.caption)
                }
                
                HStack {
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .font(.caption)
                    
                    Button(action: ({
                        let entry = CommonEntry(id: UUID(), date: selectedDate, units: intakeTypes.sortedIntakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: intakeTypes.sortedIntakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: false)
                        ChangeHistory.logger.info("Adding intake  \(name) with goalMet false")
                        Task {
                            await store.addEntry(entry: entry, goals: goals)
                        }
                    }), label: ({
                        Image(systemName: "plus.arrow.trianglehead.clockwise")
                            .padding(7)
                            .background(Color.blue.gradient, in: Capsule())
                            .foregroundColor(.white)
                    }))
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.yellow.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.accentColor.opacity(0.35), lineWidth: 2)
                    )
            )
            .frame(maxWidth: .infinity, alignment: .center)
         
            
            // Show a list of history entries for this intake type (or show all, as you prefer)
            ScrollView {
                VStack {
                    ForEach(store.history.filter { $0.name == name }.sorted { $0.date > $1.date }) { entry in
                        HStack {
                            Text(entry.name)
                                .font(.headline)
                            Spacer()
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                            Text("\(entry.amount, specifier: "%.1f") \(entry.units)")
                                .font(.caption2)
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    .animation(.default, value: store.history)
                }
//                .padding(.horizontal)
            }
            .frame(maxHeight: .infinity)
            
            Spacer()
        }
    }
}

#Preview {
    ChangeHistory()
        .environment(CommonStore())
        .environment(CommonGoals())
        .environmentObject(CurrentIntakeTypes())
}
