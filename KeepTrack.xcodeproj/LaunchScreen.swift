//  LaunchScreen.swift
//  KeepTrack
//
//  Created by Assistant on 9/12/25.
//

import SwiftUI

struct LaunchScreen: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image("AppIconImage")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .cornerRadius(28)
                .shadow(radius: 8)
            VStack(spacing: 8) {
                Text("KeepTrack")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                Text("Version \(version) (\(build))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    LaunchScreen()
}
