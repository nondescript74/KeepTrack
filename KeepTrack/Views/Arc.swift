//
//  Arc.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/25/25.
//

import SwiftUI
import OSLog

struct Arc: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "Arc")
    
    var startangle: Angle
    var endangle: Angle
    var clockwise: Bool
    var color: Color
    var size: CGFloat?
    
    var body: some View {
        ArcShape(startAngle: startangle, endAngle: endangle, clockwise: clockwise, color: color)
            .stroke(color, lineWidth: 2)
            .frame(width: (size != nil) ? size : 50, height: (size != nil) ? size : 50)
    }
}

struct ArcShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool
    var color: Color
    
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
    ZStack {
        Arc(startangle: .degrees(0), endangle: .degrees(60), clockwise: false, color: Color.red, size: 25)
        Arc(startangle: .degrees(60), endangle: .degrees(120), clockwise: false, color: Color.green, size : 35)
        Arc(startangle: .degrees(120), endangle: .degrees(180), clockwise: false, color: Color.blue, size: 45)
        Arc(startangle: .degrees(180), endangle: .degrees(240), clockwise: false, color: Color.yellow, size : 55)
        Arc(startangle: .degrees(240), endangle: .degrees(300), clockwise: false, color: Color.purple, size: 65)
        Arc(startangle: .degrees(300), endangle: .degrees(360), clockwise: false, color: Color.orange, size: 75)
        Arc(startangle: .degrees(300), endangle: .degrees(360), clockwise: false, color: Color.orange, size: 105)
    }
}
