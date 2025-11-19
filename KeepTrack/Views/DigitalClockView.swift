//  DigitalClockView.swift
//  KeepTrack
//  Created by Assistant on 9/16/25.

import SwiftUI

struct DigitalClockView: View {
    let hour: Int
    let minute: Int
    let is12HourFormat: Bool
    let isAM: Bool
    let colorGreen: Bool
    
    var timeString: String {
        let hourValue: Int
        if is12HourFormat {
            hourValue = ((hour - 1) % 12) + 1 // display 12 instead of 0, 1-12
        } else {
            hourValue = hour
        }
        let minStr = String(format: "%02d", minute)
        let hourStr = String(format: "%d", hourValue)
        var display = "\(hourStr):\(minStr)"
        if is12HourFormat {
            display += isAM ? " AM" : " PM"
        }
        return display
    }
    
    var body: some View {
        Text(timeString)
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(colorGreen ? Color.green.opacity(0.2) : Color.secondary.opacity(0.15))
            )
            .overlay(
                Capsule().stroke(colorGreen ? Color.green : Color.secondary.opacity(0.4), lineWidth: colorGreen ? 1.5 : 1)
            )
            .foregroundStyle(colorGreen ? .primary : .secondary)
            .minimumScaleFactor(0.8)
    }
}

#Preview {
    VStack(spacing: 8) {
        DigitalClockView(hour: 9, minute: 5, is12HourFormat: true, isAM: true, colorGreen: true)
        DigitalClockView(hour: 13, minute: 45, is12HourFormat: false, isAM: false, colorGreen: false)
        DigitalClockView(hour: 0, minute: 0, is12HourFormat: true, isAM: true, colorGreen: false)
    }
    .padding()
}
