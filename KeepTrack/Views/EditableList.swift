//
//  EditableList.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/20/25.
//

import SwiftUI
import OSLog

struct EditableList<Element: Identifiable, Content: View>: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EditableList")
    
    @Environment(Water.self) var water
    
    
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
                            water.removeWaterAtId(uuid: id as! UUID)
                        }
                    }
            }
            .toolbar { EditButton() }
        }
}

#Preview {
//    @Previewable @Environment(Water.self) var water
//    @Previewable @State var items: [WaterEntry] = []
//    EditableList<WaterEntry, <#Content: View#>>($items)
//        
//     
}
