//
//  EmptyDataBackground.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 5/5/25.
//

import SwiftUI

struct EmptyDataBackground: View {
    
    var labelText: String!
    
    init(message: String) {
        self.labelText = message
    }
    var body: some View {
        Label(labelText, systemImage: "circle")
            .foregroundStyle(.secondary)
            .alignmentGuide(.bottom) { $0[VerticalAlignment.bottom] }
            .font(.system(size: 22, weight: .regular))
    }
}
#Preview {
    EmptyDataBackground(message: "no data")
}
