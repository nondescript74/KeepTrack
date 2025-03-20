//
//  EnterWater.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/18/25.
//

import SwiftUI
import OSLog

struct EnterWater: View {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "EnterWater")
    @Environment(Water.self) fileprivate var water
    @State var waterIntake: Int = 1
    
    var body: some View {
        HStack {
            Text("Enter water intake")
            Picker("Water Intake", selection: $waterIntake) {
                ForEach(1...3, id: \.self) {
                    Text("\($0)")
                }
            }
            .onChange(of: waterIntake) { newValue in
                logger.info("waterIntake changed to \(newValue)")
            }
            
            Button("Add") {
                water.addWater(waterIntake)
            }
        }
    }
}

#Preview {
    EnterWater(waterIntake: 3)
        .environment(Water())
}
