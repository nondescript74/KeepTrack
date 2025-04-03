//
//  MovableGoalsList.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/3/25.
//

import SwiftUI
import OSLog

struct MovableGoalsList<Element: Identifiable, Content: View>: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "MovableGoalsList")
    
    @Environment(Goals.self) var goals
    
    @Binding var data: [Element]
    
    var content: (Binding<Element>) -> Content
    
    init(_ data: Binding<[Element]>, content: @escaping (Binding<Element>) -> Content) {
        self._data = data
        self.content = content
    }
    
    fileprivate func move(from source: IndexSet, to destination: Int) {
        goals.goals.move(fromOffsets: source, toOffset: destination)
    }
    
    var body: some View {
        List {
            ForEach($data, content: content)
                .onMove(perform: move)
        }
        .toolbar { EditButton() }
        .environment(goals)
    }
}
