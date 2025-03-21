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
    @Binding var items: [WaterEntry]
    
    
    var body: some View {
        NavigationView {
            VStack {
                EditableList($items) { item in
                    Text(item.id.uuidString)
                }
            }
            .navigationTitle(Text("Edit Water History"))
        }
    }
}

#Preview {
    @Previewable @State var items: [WaterEntry] = [WaterEntry(id: UUID(), date: Date(), units: 1), WaterEntry(id: UUID(), date: Date(), units: 2)]
    EditWaterHistory(items: $items)
    
}
