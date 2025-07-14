//
//  ChangeHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/11/25.
//

import SwiftUI
import OSLog

struct ChangeHistory: View {
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ChangeHistory")
    @Environment(CommonStore.self) private var store
    @Environment(CurrentIntakeTypes.self) private var intakeTypes
    
    @State private var selectedIntakeType: IntakeType?
    @State private var selectedDate: Date = Date()
    @State private var name: String = "Water"
    
    var body: some View {
        VStack {
            HStack {
                Picker("Select Type", selection: $name) {
                    ForEach(intakeTypes.intakeTypeNameArray.sorted(by: {$0 < $1}), id: \.self) {
                        Text($0)
                    }
                }
                DatePicker(
                    "Date",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            
            Button(action: ({
                let entry = CommonEntry(id: UUID(), date: selectedDate, units: intakeTypes.intakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: intakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: false)
                logger.info("Adding intake  \(name) with goalMet false")
                store.addEntry(entry: entry)
                
                
            }), label: ({
                Image(systemName: "plus.arrow.trianglehead.clockwise")
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
            }))
            .padding()
            .foregroundStyle(.blue)
            
        }
        .environment(store)
        .environment(intakeTypes)
    }
}

#Preview {
    ChangeHistory()
        .environment(CommonStore())
        .environment(CurrentIntakeTypes())
}
