//
//  Clock.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 6/2/25.
//

import SwiftUI
import Foundation

struct Clock: View {
    
    init(hour: Int, minute: Int, is12HourFormat: Bool) {
        self.hour = hour
        self.minute = minute
        self.is12HourFormat = is12HourFormat
    }
    
    @State private var hour: Int
    @State private var minute: Int
    @State private var is12HourFormat: Bool
    
    fileprivate let angleCorrection: Int = 180
    fileprivate let clockDiameter: CGFloat = 35
    fileprivate let clockInsideDiameter: CGFloat = 5
    fileprivate let minuteHandLength: CGFloat = 15
    fileprivate let hourHandLength: CGFloat = 12
    fileprivate let letterOffset: CGFloat = 35
    
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 1))
                .frame(width: clockDiameter, height: clockDiameter)
            
            Circle()
                .fill(Color.black)
                .frame(width: clockInsideDiameter, height: clockInsideDiameter)
            
//            Text("9")
//                .offset(x: -letterOffset)
//                .font(.caption)
//            Text("3")
//                .offset(x: letterOffset)
//                .font(.caption)
//            Text("12")
//                .offset(y: -letterOffset)
//                .font(.caption)
//            Text("6")
//                .offset(y: letterOffset)
//                .font(.caption)
            
            Rectangle()
                .fill(Color.red)
                .frame(width: 3, height: minuteHandLength)
                .offset(y: 12)
                .rotationEffect(Angle(degrees: Double(6 * minute + angleCorrection)))
            
            Rectangle()
                .fill(Color.red)
                .frame(width: 5, height: hourHandLength)
                .offset(y: 11)
                .rotationEffect(Angle(degrees: Double(30 * hour + angleCorrection)))
        }

    }
}

#Preview {
    Clock(hour: 9, minute: 59, is12HourFormat: true)
}
