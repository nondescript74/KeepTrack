//
//  MovableGoalList.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import SwiftUI
import OSLog

struct MovableGoalList<Element: Identifiable, Content: View>: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "MovableGoalList")
    
    @Environment(CommonGoals.self) var goals
    
    @Binding var data: [Element]
    
    var content: (Binding<Element>) -> Content
    
    init(_ data: Binding<[Element]>, content: @escaping (Binding<Element>) -> Content) {
        self._data = data
        self.content = content
    }
    
    fileprivate func move(from source: IndexSet, to destination: Int) {
        goals.goals.move(fromOffsets: source, toOffset: destination)
    }
    
    fileprivate func delete(at offsets: IndexSet) {
        // Prevent crash when deleting last item
        guard !data.isEmpty else { return }
        
        for idx in offsets {
            if idx >= 0 && idx < data.count {
                goals.removeGoalAtId(uuid: data[idx].id as! UUID)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach($data, content: content)
                .onMove(perform: move)
                .onDelete(perform: delete)
        }
        .toolbar { EditButton() }
        .environment(goals)
    }
}

