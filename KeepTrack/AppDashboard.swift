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
    @State private var cIntakeTypes = CurrentIntakeTypes()
    
    fileprivate let columnLayout = Array(repeating: GridItem(.flexible(minimum: 45)), count: 5  )
    
    fileprivate let heightOfBar: CGFloat = 40
    
    var body: some View {
        NavigationStack {
            History()
                .padding(.bottom, 15)
                                    
            GoalDisplayByName()
            
            Spacer()
            HStack {
                VStack {
                    NavigationLink(destination: EnterIntake()) {
                        ZStack {
                            Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50)
                            Image(systemName: "wineglass")
                                .foregroundStyle(Color.red)
                                .symbolRenderingMode(.multicolor)
                                .frame(minHeight: heightOfBar)
                        }
                    }
                    Text("Enter Intake")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EnterGoal()) {
                        ZStack {
                            Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50)
                            Image(systemName: "microphone.badge.plus")
                                .foregroundStyle(Color.red)
                                .symbolRenderingMode(.multicolor)
                                .frame(minHeight: heightOfBar)
                        }
                    }
                    Text("Enter Goal")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EditHistory(items: $store.history)) {
                        ZStack {
                            Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50)
                            Image(systemName: "heart.text.clipboard")
                                .foregroundStyle(Color.red)
                                .symbolRenderingMode(.multicolor)
                                .frame(minHeight: heightOfBar)
                        }
                    }
                    Text("Edit Intake")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
                .padding(.top)
                VStack {
                    NavigationLink(destination: EditGoals(items: $goals.goals)) {
                        ZStack {
                            Circle().stroke(Color.black, lineWidth: 2).frame(width:50, height:50)
                            Image(systemName: "figure.hockey")
                                .foregroundStyle(Color.red)
                                .symbolRenderingMode(.multicolor)
                                .frame(minHeight: heightOfBar)
                        }
                    }
                    Text("Edit Goals")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .padding(.top)
            }
            .padding([.horizontal], 3)
            .background(Color.gray.opacity(0.2))
            
            Spacer()
            
            HStack {
                Text("Welcome to KeepTrack!")
                Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                Text(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
            }
            .font(.subheadline)
        }
        .environment(goals)
        .environment(store)
        .environment(healthKitManager)
        .environment(cIntakeTypes)
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
        .environment(CurrentIntakeTypes())
}
