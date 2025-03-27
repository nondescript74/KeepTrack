//
//  EditableGoalsList.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/26/25.
//

import SwiftUI
import OSLog

struct EditableGoalsList<Element: Identifiable, Content: View>: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditableGoalsList")
    
    @Environment(Goals.self) var goals
    
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
                        goals.removeGoalAtId(uuid: id as! UUID)
                    }
                }
        }
        .toolbar { EditButton() }
        .environment(goals)
    }
}
