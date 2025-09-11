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
        self.colorGreen = false
    }
    
    init (hour: Int, minute: Int, is12HourFormat: Bool, isAM: Bool, colorGreen: Bool) {
        self.hour = hour
        self.minute = minute
        self.is12HourFormat = is12HourFormat
        self.isAM = isAM
        self.colorGreen = colorGreen
    }
    
    @State private var hour: Int
    @State private var minute: Int
    @State private var is12HourFormat: Bool
    @State private var isAM: Bool
    @State private var colorGreen: Bool
    
    fileprivate let angleCorrection: Int = 180
    fileprivate let clockDiameter: CGFloat = 50
    fileprivate let clockInsideDiameter: CGFloat = 5
    
    fileprivate let minuteHandWidth: CGFloat = 2
    
    fileprivate let indicatorsWidth: CGFloat = 3
    
    var body: some View {
        ZStack {
            // Gold wristwatch outer ring
            Circle()
                .strokeBorder(
                    AngularGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.9), Color.orange, Color.yellow, Color(.systemYellow), Color(.brown), Color.yellow.opacity(0.9)]), center: .center),
                    lineWidth: 5
                )
                .shadow(color: .yellow.opacity(0.36), radius: 7, x: 0, y: 2)
                .frame(width: clockDiameter + 12, height: clockDiameter + 12)
            // Inner shadow for realism
            Circle()
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1.3)
                .frame(width: clockDiameter + 8, height: clockDiameter + 8)

            // ---- Existing clock face starts here ----
            ZStack {
                // Radial gradient background
                Circle()
                    .fill(RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.18), Color.white]), center: .center, startRadius: 10, endRadius: 110))
                    .shadow(color: .blue.opacity(0.28), radius: 10, x: 0, y: 6)
                    .background(.ultraThinMaterial, in: Circle())
                    .frame(width: clockDiameter, height: clockDiameter)
                
                // Crystal reflection (glass shine)
                Circle()
                    .fill(Color.clear)
                    .frame(width: clockDiameter, height: clockDiameter)
                    .overlay(
                        Ellipse()
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.28), Color.white.opacity(0.05), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: clockDiameter * 0.7, height: clockDiameter * 0.32)
                            .offset(x: -clockDiameter * 0.12, y: -clockDiameter * 0.24)
                            .blur(radius: 0.6)
                    )
                    .allowsHitTesting(false)
                
                // Minute ticks (60)
                ForEach(0..<60) { tick in
                    Capsule()
                        .fill(Color.gray.opacity(tick % 5 == 0 ? 0.4 : 0.17))
                        .frame(width: tick % 5 == 0 ? 2 : 1, height: tick % 5 == 0 ? 7 : 2)
                        .offset(y: -(clockDiameter / 2) + (tick % 5 == 0 ? 6 : 8))
                        .rotationEffect(Angle(degrees: Double(tick) * 6))
                }
                // Hour ticks (12, overlay for emphasis)
                ForEach(0..<12) { hour in
                    Capsule()
                        .fill(Color.primary.opacity(0.55))
                        .frame(width: 2.5, height: 11)
                        .offset(y: -(clockDiameter / 2) + 8)
                        .rotationEffect(Angle(degrees: Double(hour) * 30))
                }
                // Hour hand
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black)
                    .frame(width: 4, height: clockDiameter / 3)
                    .shadow(radius: 1.5)
                    .offset(y: -clockDiameter / 6)
                    .rotationEffect(Angle(degrees: Double(30 * hour + (minute / 2) + angleCorrection)))
                // Minute hand
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red)
                    .frame(width: 2.5, height: clockDiameter / 2)
                    .shadow(radius: 1, y: 1)
                    .offset(y: -clockDiameter / 4)
                    .rotationEffect(Angle(degrees: Double(6 * minute + angleCorrection)))
                // Center disc with highlight
                Circle()
                    .fill(Color.white)
                    .frame(width: 13, height: 13)
                    .shadow(color: .blue.opacity(0.12), radius: 2)
                    .overlay(Circle().stroke(Color.black.opacity(0.13), lineWidth: 1))
                // AM/PM badge inside
                if is12HourFormat {
                    Text(isAM ? "AM" : "PM")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .foregroundColor(.blue)
                        .offset(y: clockDiameter / 3.4)
                        .shadow(radius: 0.3)
                }
            }
            // ---- End of existing clock face ----
        }
        .frame(width: clockDiameter + 34, height: clockDiameter + 34)
        .padding(8)
    }
}

#Preview {
    Clock(hour: 9, minute: 5, is12HourFormat: true, isAM: true)
}
