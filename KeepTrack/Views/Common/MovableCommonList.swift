//
//  MovableCommonList.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import SwiftUI
import OSLog

struct MovableCommonList<Element: Identifiable, Content: View>: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "MovableCommonList")
    
    @Environment(Goals.self) var goals
    @Environment(MedGoals.self) var medGoals
    fileprivate var type: String
    
    @Binding var data: [Element]
    
    var content: (Binding<Element>) -> Content
    
    init(_ data: Binding<[Element]>, type: String, content: @escaping (Binding<Element>) -> Content) {
        self._data = data
        self.content = content
        self.type = type
    }
    
    fileprivate func move(from source: IndexSet, to destination: Int) {
        switch type.lowercased() {
        case "water":
            goals.goals.move(fromOffsets: source, toOffset: destination)
            logger.info("moved goal")
            case "meds":
            medGoals.medGoals.move(fromOffsets: source, toOffset: destination)
            logger.info( "moved med")
        default:
            logger.warning("Unsupported type \(type)")
        }
        
    }
    
    var body: some View {
        List {
            ForEach($data, content: content)
                .onMove(perform: move)
        }
        .toolbar { EditButton() }
        .environment(goals)
        .environment(medGoals)
    }
}
