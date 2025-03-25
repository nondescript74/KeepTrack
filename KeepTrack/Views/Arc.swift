//
//  Arc.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/25/25.
//

import SwiftUI
import OSLog

struct Arc: View {
//    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Arc")
    var body: some View {
        ArcShape(startAngle: .degrees(270), endAngle: .degrees(330), clockwise: false)
            .stroke(.green, lineWidth: 5)
            .frame(width: 50, height: 50)
    }
}

#Preview {
    Arc()
}

struct ArcShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: clockwise
        )
        return path
    }
}
#Preview {
    ArcShape(startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
}
