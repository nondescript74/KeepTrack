//
//  Clock.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 6/2/25.
//

import SwiftUI
import Foundation

struct Clock: View {
    
    init(hour: Int, minute: Int, is12HourFormat: Bool, isAM: Bool) {
        self.hour = hour
        self.minute = minute
        self.is12HourFormat = is12HourFormat
        self.isAM = isAM
    }
    
    @State private var hour: Int
    @State private var minute: Int
    @State private var is12HourFormat: Bool
    @State private var isAM: Bool
    @State private var backgroundColorAM: Color = Color.blue.opacity(0.4)
    @State private var backgroundColorPM: Color = Color.gray.opacity(0.4)
    
    fileprivate let angleCorrection: Int = 180
    fileprivate let clockDiameter: CGFloat = 30
    fileprivate let clockInsideDiameter: CGFloat = 2
    
    fileprivate let minuteHandWidth: CGFloat = 2
    
    fileprivate let indicatorsWidth: CGFloat = 3
    
    fileprivate let hourHandLength: CGFloat = 12
    fileprivate let letterOffset: CGFloat = 20
    
    
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
                    .frame(width: minuteHandWidth, height: clockDiameter - 18)
                    .offset(y: clockDiameter / 4 )
                    .rotationEffect(Angle(degrees: Double(6 * minute + angleCorrection)))
                
                Rectangle()
                    .fill(Color.black)
                    .frame(width: minuteHandWidth + 2, height: clockDiameter - 20)
                    .offset(y: clockDiameter / 4)
                    .rotationEffect(Angle(degrees: Double(30 * hour + angleCorrection)))
                
                ForEach(0..<4) { index in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: indicatorsWidth, height: indicatorsWidth)
                        .offset(y: clockDiameter / 2)
                        .rotationEffect(Angle(degrees: Double(90 * index + angleCorrection)))
                }
                
                Text(isAM ? "AM" : "PM")
                    .font(.system(size: 10))
                    .offset(y: -letterOffset)
        }
            .padding(5)
    }
}

#Preview {
    Clock(hour: 9, minute: 5, is12HourFormat: true, isAM: true)
}
