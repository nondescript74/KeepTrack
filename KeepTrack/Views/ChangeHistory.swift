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
    @EnvironmentObject private var intakeTypes: CurrentIntakeTypes
    
    @State private var selectedIntakeType: IntakeType?
    @State private var selectedDate: Date = Date()
    @State private var name: String = "Water"
    
    var body: some View {
        VStack {
            HStack {
                Picker("Select Type", selection: $name) {
                    ForEach(intakeTypes.sortedIntakeTypeNameArray, id: \.self) {
                        Text($0)
                    }
                }
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            
            Button(action: ({
                let entry = CommonEntry(id: UUID(), date: selectedDate, units: intakeTypes.sortedIntakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: intakeTypes.sortedIntakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: false)
                ChangeHistory.logger.info("Adding intake  \(name) with goalMet false")
                Task {
                    await store.addEntry(entry: entry)
                }
            }), label: ({
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
            }))
            .padding()
            .foregroundStyle(.blue)
            
        }
    }
}

#Preview {
    ChangeHistory()
        .environment(CommonStore())
        .environmentObject(CurrentIntakeTypes())
}
