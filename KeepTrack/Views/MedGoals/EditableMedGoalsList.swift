//
//  EditableMedGoalsList.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/30/25.
//

import SwiftUI
import OSLog

struct EditableMedGoalsList<Element: Identifiable, Content: View>: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditableMedGoalsList")
    
    @Environment(MedGoals.self) var goals
    
    @Binding var data: [Element]
    
    var content: (Binding<Element>) -> Content
    
    init(_ data: Binding<[Element]>, content: @escaping (Binding<Element>) -> Content) {
        self._data = data
        self.content = content
    }
    
    fileprivate func move(from source: IndexSet, to destination: Int) {
        goals.medGoals.move(fromOffsets: source, toOffset: destination)
    }
    
    var body: some View {
        List {
            ForEach($data, content: content)
                .onMove(perform: move)
                .onDelete { indexSet in
                    for idx in indexSet.reversed() {
                        let id = data[idx].id
                        goals.removeMedGoalAtId(uuid: id as! UUID)
                    }
                }
        }
        .toolbar { EditButton() }
        .environment(goals)
    }
}
