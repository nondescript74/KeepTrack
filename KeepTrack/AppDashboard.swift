//
//  AppDashboard.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/19/25.
//

import Foundation
import SwiftUI
import OSLog
import HealthKit

struct AppDashboard: View {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "AppDashboard")
    @State private var store: CommonStore = CommonStore()
    @State private var goals: CommonGoals = CommonGoals()
    let columnLayout = Array(repeating: GridItem(.flexible(minimum: 45)), count: 4  )
    
    var body: some View {
        NavigationStack {
            HStack {
                Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                Text(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
            }
            .padding(.horizontal)
            .font(.footnote)

            History()
            
//            HistoryHK(dataTypeIdentifier: HKQuantityTypeIdentifier.dietaryWater.rawValue)
            
            GoalDisplayByName()
                
            LazyVGrid(columns: columnLayout, alignment: .center) {
                VStack {
                    NavigationLink(destination: EnterIntake()) {
                        Image(systemName: "wineglass")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 50)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50))
                    Text("Enter intake")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(.top)

                VStack {
                    NavigationLink(destination: EnterGoal()) {
                        Image(systemName: "sportscourt.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 50)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50))
                    Text("Enter Goal")
                        .foregroundColor(.blue)
                        .font(.caption)
                }

                .padding(.top)
                VStack {
                    NavigationLink(destination: EditHistory(items: $store.history)) {
                        Image(systemName: "heart.text.clipboard")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 50)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50))
                    Text("Edit Intake")
                        .foregroundColor(.red)
                        .font(.caption)
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
                        .font(.caption)
                }
                .padding(.top)
            }
            .padding([.horizontal, .bottom])
            .background(Color.gray.opacity(0.2))
            
        }
        .environment(goals)
        .environment(store)
    }
}

#Preview {
    AppDashboard()
        .environment(CommonGoals())
        .environment(CommonStore())
}
