//
//  EnterWater.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/18/25.
//

import SwiftUI

struct EnterWater: View {
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
                print(newValue)
            }

        }
    }
}

#Preview {
    EnterWater(waterIntake: 3)
}
