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
    @State private var medGoals: MedGoals = MedGoals()
    let columnLayout = Array(repeating: GridItem(.flexible(minimum: 45)), count: 8)
    
    var body: some View {
        NavigationStack {
            WaterHistory()
                
            MedHistory()
                
            LazyVGrid(columns: columnLayout, alignment: .center) {
                VStack {
                    NavigationLink(destination: EnterWater()) {
                        Image(systemName: "wineglass")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 40)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:40, height:40))
                    Text("Enter Water taken")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EnterMedication()) {
                        Image(systemName: "fork.knife.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 40)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:40, height:40))
                    Text("Enter Med taken")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EnterWaterTimeGoal()) {
                        Image(systemName: "sportscourt.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 40)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:40, height:40))
                    Text("Enter Water Goal")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EnterMedTimeGoal()) {
                        Image(systemName: "sportscourt.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 40)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:40, height:40))
                    Text("Enter Med Goal")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EditWaterHistory(items: $water.waterHistory)) {
                        Image(systemName: "heart.text.clipboard")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 40)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:40, height:40))
                    Text("Edit Water History")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EditMedHistory(items: $medicationStore.medicationHistory)) {
                        Image(systemName: "heart.text.clipboard")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 40)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:40, height:40))
                    Text("Edit Meds History")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EditGoals(items: $goals.goals)) {
                        Image(systemName: "sportscourt")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 40)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:40, height:40))
                    Text("Edit Water Goals")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EditMedGoals(items: $medGoals.medGoals)) {
                        Image(systemName: "sportscourt.fill")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 40)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:40, height:40))
                    Text("Edit Med Goals")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .padding(.top)
            }
            .overlay(Rectangle().stroke(style: StrokeStyle(lineWidth: 2)))
            .background(Color.gray.opacity(0.2))
            
        }
        .environment(water)
        .environment(medicationStore)
        .environment(goals)
        .environment(medGoals)
    }
}

#Preview {
    AppDashboard()
        .environment(Water())
        .environment(MedicationStore())
        .environment(Goals())
        .environment(MedGoals())
}
