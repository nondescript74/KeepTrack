//
//  EditableMedList.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/24/25.
//

import SwiftUI
import OSLog

struct EditableMedList<Element: Identifiable, Content: View>: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditableMedList")
    
    @Environment(MedicationStore.self) var medicationStore
    
    @Binding var data: [Element]
    
    var content: (Binding<Element>) -> Content
    
    init(_ data: Binding<[Element]>, content: @escaping (Binding<Element>) -> Content) {
        self._data = data
        self.content = content
    }
    
    var body: some View {
        List {
            ForEach($data, content: content)
                .onDelete { indexSet in
                    for idx in indexSet.reversed() {
                        let id = data[idx].id
                        medicationStore.removeMedicationAtId(uuid: id as! UUID)
                    }
                }
        }
        .toolbar { EditButton() }
    }
}
