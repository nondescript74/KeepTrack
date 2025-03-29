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
    @State private var goals: Goals = Goals()
    
    let columnLayout = Array(repeating: GridItem(.flexible(minimum: 50)), count: 6)
    
    var body: some View {
        NavigationStack {
            WaterHistory()
                
            MedHistory()
                
            LazyVGrid(columns: columnLayout) {
                VStack {
                    NavigationLink(destination: EnterWater()) {
                        Image(systemName: "wineglass")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 50)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50))
                    Text("Enter Water")
                        .foregroundColor(.blue)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EnterMedication()) {
                        Image(systemName: "fork.knife.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 50)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50))
                    Text("Enter Meds")
                        .foregroundColor(.blue)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EnterWaterTimeGoal()) {
                        Image(systemName: "sportscourt.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 50)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50))
                    Text("Enter Goal")
                        .foregroundColor(.blue)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EditWaterHistory(items: $water.waterHistory)) {
                        Image(systemName: "heart.text.clipboard")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 50)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50))
                    Text("Edit Water")
                        .foregroundColor(.red)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EditMedHistory(items: $medicationStore.medicationHistory)) {
                        Image(systemName: "heart.text.clipboard")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 50)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50))
                    Text("Edit Meds")
                        .foregroundColor(.red)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EditGoals(items: $goals.goals)) {
                        Image(systemName: "sportscourt")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 50)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50))
                    Text("Edit Goals")
                        .foregroundColor(.red)
                }
                .padding(.top)
            }
            .padding(.all, 5)
            .overlay(Rectangle().stroke(style: StrokeStyle(lineWidth: 2)))
            .background(Color.gray.opacity(0.2))
            .padding(.horizontal, 10)
            
        }
        .environment(water)
        .environment(medicationStore)
        .environment(goals)
    }
}

#Preview {
    AppDashboard()
        .environment(Water())
        .environment(MedicationStore())
        .environment(Goals())
}
