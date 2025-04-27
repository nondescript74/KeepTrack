//
//  EditHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/14/25.
//

import SwiftUI
import OSLog

struct EditHistory: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditHistory")
    
    @Environment(CommonStore.self) var store
    @Binding var items: [CommonEntry]
    
    
    var body: some View {
        NavigationView {
            VStack {
                MovableHistoryList($items) { item in
                    HStack {
                        Text("\(item.date.wrappedValue.formatted(date: .abbreviated, time: .standard))")
                        Text("\(item.name.wrappedValue)")
                    }
                }
            }
            .navigationTitle(Text("Edit History"))
        }
        .environment(store)
    }
}

#Preview {
    @Previewable @State var items: [CommonEntry] = [CommonEntry(id: UUID(), date: Date(), units: "mg", amount: 500, name: "Metformin", goalMet: true), CommonEntry(id: UUID(), date: Date(), units: "mg", amount: 20, name: "Rosuvastatin", goalMet: false), CommonEntry(id: UUID(), date: Date(), units: "mg", amount: 25, name: "Losartan", goalMet: true)]
    EditHistory(items: $items)
        .environment(CommonStore())
}

