//
//  MovableMedGoalsList.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/6/25.
//

import SwiftUI
import OSLog

struct MovableMedGoalsList<Element: Identifiable, Content: View>: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "MovableMedGoalsList")
    
    @Environment(MedGoals.self) var medgoals
    
    @Binding var data: [Element]
    
    var content: (Binding<Element>) -> Content
    
    init(_ data: Binding<[Element]>, content: @escaping (Binding<Element>) -> Content) {
        self._data = data
        self.content = content
    }
    
    fileprivate func move(from source: IndexSet, to destination: Int) {
        medgoals.medGoals.move(fromOffsets: source, toOffset: destination)
    }
    
    fileprivate func delete(at offsets: IndexSet) {
        for idx in offsets {
            medgoals.medGoals[idx].isActive = false
            medgoals.removeMedGoalAtId(uuid: data[idx].id as! UUID)
        }
    }
    
    var body: some View {
        List {
            ForEach($data, content: content)
                .onMove(perform: move)
                .onDelete(perform: delete)
        }
        .toolbar { EditButton() }
        .environment(medgoals)
    }
}

