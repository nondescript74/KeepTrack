//
//  AppDashboard.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/19/25.
//

import Foundation
import SwiftUI
import OSLog

struct AppDashboard: View {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "AppDashboard")
    @State private var water = Water()
    @State private var medicationStore: MedicationStore = MedicationStore()
    
    let columnLayout = Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)
    let rowLayout = Array(repeating: GridItem(.flexible(minimum: 100)), count: 5)
    
    var body: some View {
        NavigationStack {
            HStack {
                WaterHistory()
                MedHistory()
            }
            LazyVGrid(columns: columnLayout) {
                VStack {
                    NavigationLink(destination: EnterMedication()) {
                        Image(systemName: "fork.knife.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 70)
                    }
                    .padding(.horizontal)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2).frame(width:50, height:50))
                    .padding(.horizontal)
                    Text("Enter Meds")
                        .padding(.horizontal)
                        .foregroundColor(.blue)
                }
                VStack {
                    NavigationLink(destination: EnterWater()) {
                        Image(systemName: "wineglass")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 70)
                    }
                    .padding(.horizontal)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2).frame(width:50, height:50))
                    .padding(.horizontal)
                    Text("Enter Water")
                        .padding(.horizontal)
                        .foregroundColor(.blue)
                }
                VStack {
                    NavigationLink(destination: EditWaterHistory(items: $water.waterHistory)) {
                        Image(systemName: "heart.text.clipboard")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 70)
                    }
                    .padding(.horizontal)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2).frame(width:50, height:50))
                    .padding(.horizontal)
                    Text("Edit Water")
                        .padding(.horizontal)
                        .foregroundColor(.red)
                }
                VStack {
                    NavigationLink(destination: EditMedHistory(items: $medicationStore.medicationHistory)) {
                        Image(systemName: "heart.text.clipboard")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 70)
                    }
                    .padding(.horizontal)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2).frame(width:50, height:50))
                    .padding(.horizontal)
                    Text("Edit meds")
                        .padding(.horizontal)
                        .foregroundColor(.red)
                }
            }
            Spacer()
        }
        .environment(water)
        .environment(medicationStore)
    }
}

#Preview {
    AppDashboard()
        .environment(Water())
        .environment(MedicationStore())
}
