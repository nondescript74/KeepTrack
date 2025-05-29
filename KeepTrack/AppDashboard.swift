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
import VisionKit

struct AppDashboard: View {
    fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "AppDashboard")
    @State private var store: CommonStore = CommonStore()
    @State private var goals: CommonGoals = CommonGoals()
    @State private var healthKitManager = HealthKitManager()
    
    fileprivate let columnLayout = Array(repeating: GridItem(.flexible(minimum: 45)), count: 5  )
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Welcome to KeepTrack!")
                    Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                    Text(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
                }
//                Text(healthKitManager.descriptionLabel)
//                    .font(.footnote)
            }
            .padding(.bottom, 20)
            
            History()
                        
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
                VStack {
                    NavigationLink(destination: DisplayHKHistory()) {
                        Image(systemName: "heart")
                            .symbolRenderingMode(.multicolor)
                            .frame(minHeight: 50)
                    }
                    .overlay(Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50))
                    Text("HealthKit")
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
        .environment(healthKitManager)
        #if os(VisionOS)
        .glassBackgroundEffect()
        #endif
    }
}

#Preview {
    AppDashboard()
        .environment(CommonGoals())
        .environment(CommonStore())
        .environment(HealthKitManager())
}
