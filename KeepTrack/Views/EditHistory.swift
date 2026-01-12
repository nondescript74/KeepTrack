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
        VStack(alignment: .leading, spacing: 12) {
            Text("Edit History")
                .font(.title2.bold())
                .foregroundColor(.accentColor)
            
            MovableHistoryList($items) { item in
                HStack {
                    if item.goalMet.wrappedValue {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name.wrappedValue)
                            .fontWeight(.semibold)
                        Text(item.date.wrappedValue.formatted(date: .abbreviated, time: .standard))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(item.amount.wrappedValue, specifier: "%.1f") \(item.units.wrappedValue)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.08)))
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                .padding(.vertical, 4)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            .animation(.default, value: items)
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemGroupedBackground))
        #else
        .background(Color(nsColor: .controlBackgroundColor))
        #endif
        .environment(store)
    }
}

#Preview {
    @Previewable @State var items: [CommonEntry] = [CommonEntry(id: UUID(), date: Date(), units: "mg", amount: 500, name: "Metformin", goalMet: true), CommonEntry(id: UUID(), date: Date(), units: "mg", amount: 20, name: "Rosuvastatin", goalMet: false), CommonEntry(id: UUID(), date: Date(), units: "mg", amount: 25, name: "Losartan", goalMet: true)]
    EditHistory(items: $items)
        .environment(CommonStore())
}
