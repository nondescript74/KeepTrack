//
//  EditWaterHistory.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/20/25.
//

import SwiftUI
import OSLog

struct EditWaterHistory: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditWaterHistory")
    @Environment(Water.self) var water
    @Binding var items: [WaterEntry]
    
    
    var body: some View {
        NavigationView {
            VStack {
                EditableList($items) { item in
                    Text("\(item.date.wrappedValue.formatted(date: .abbreviated, time: .standard))" + ": " + "\(item.units.wrappedValue)" + " units")
                }
            }
            .navigationTitle(Text("Edit Water History"))
        }
        .environment(water)
    }
}

#Preview {
    @Previewable @State var items: [WaterEntry] = [WaterEntry(id: UUID(), date: Date(), units: 1), WaterEntry(id: UUID(), date: Date(), units: 2)]
    EditWaterHistory(items: $items)
        .environment(Water())
    
}
