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
    fileprivate let clockDiameter: CGFloat = 30
    fileprivate let clockInsideDiameter: CGFloat = 2
    
    fileprivate let minuteHandWidth: CGFloat = 2
    
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
            
            Rectangle()
                .fill(Color.red)
                .frame(width: minuteHandWidth, height: clockDiameter - 20)
                .offset(y: clockDiameter / 2 - 3)
                .rotationEffect(Angle(degrees: Double(6 * minute + angleCorrection)))
            
            Rectangle()
                .fill(Color.black)
                .frame(width: minuteHandWidth + 2, height: clockDiameter - 20)
                .offset(y: clockDiameter / 2 - 5)
                .rotationEffect(Angle(degrees: Double(30 * hour + angleCorrection)))
        }
    }
}

#Preview {
    Clock(hour: 9, minute: 5, is12HourFormat: true)
}
