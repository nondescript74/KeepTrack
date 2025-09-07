//
//  ChangeHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 7/11/25.
//

import SwiftUI
import OSLog

private struct CommonStoreKey: EnvironmentKey {
    static let defaultValue: CommonStore? = nil
}
extension EnvironmentValues {
    var commonStore: CommonStore? {
        get { self[CommonStoreKey.self] }
        set { self[CommonStoreKey.self] = newValue }
    }
}

private struct CurrentIntakeTypesKey: EnvironmentKey {
    static let defaultValue: CurrentIntakeTypes? = nil
}
extension EnvironmentValues {
    var currentIntakeTypes: CurrentIntakeTypes? {
        get { self[CurrentIntakeTypesKey.self] }
        set { self[CurrentIntakeTypesKey.self] = newValue }
    }
}

struct ChangeHistory: View {
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "ChangeHistory")
    @Environment(\.commonStore) private var store: CommonStore?
    @Environment(\.currentIntakeTypes) private var intakeTypes: CurrentIntakeTypes?
    
    @State private var selectedIntakeType: IntakeType?
    @State private var selectedDate: Date = Date()
    @State private var name: String = "Water"
    
    var body: some View {
        if let intakeTypes = intakeTypes, let store = store {
            VStack {
                HStack {
                    Picker("Select Type", selection: $name) {
                        ForEach(intakeTypes.intakeTypeNameArray.sorted(by: {$0 < $1}), id: \.self) {
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
                    let entry = CommonEntry(id: UUID(), date: selectedDate, units: intakeTypes.intakeTypeArray.first(where: {$0.name == name})?.unit ?? "no unit", amount: intakeTypes.intakeTypeArray.first(where: {$0.name == name})?.amount ?? 0, name: name, goalMet: false)
                    ChangeHistory.logger.info("Adding intake  \(name) with goalMet false")
                    store.addEntry(entry: entry)
                    
                    
                }), label: ({
                    Image(systemName: "plus.arrow.trianglehead.clockwise")
                        .padding(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2)))
                }))
                .padding()
                .foregroundStyle(.blue)
                
            }
        } else {
            Text("Intake types or store not loaded")
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

#Preview {
    ChangeHistory()
        .environment(\.commonStore, CommonStore())
        .environment(\.currentIntakeTypes, CurrentIntakeTypes())
}
