//
//  DashboardWithPermissionBanner.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import SwiftUI

/// Wrapper view that displays permission warnings above any content
struct DashboardWithPermissionBanner<Content: View>: View {
    @EnvironmentObject var permissionsChecker: SystemPermissionsChecker
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Permission warning banner at top
            PermissionWarningBanner(permissionsChecker: permissionsChecker)
            
            // Main content
            content
        }
    }
}

#Preview {
    let checker = SystemPermissionsChecker.shared
    checker.hasWarnings = true
    checker.warningMessages = [
        PermissionWarning(
            id: "test",
            severity: .critical,
            title: "iCloud Not Available",
            message: "Please sign in to iCloud in Settings to enable data sync",
            action: .openSettings
        )
    ]
    
    return DashboardWithPermissionBanner {
        VStack {
            Text("Main Dashboard Content")
                .font(.largeTitle)
            Spacer()
        }
    }
    .environmentObject(checker)
}
