//
//  PermissionWarningBanner.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import SwiftUI

/// Displays permission warnings at the top of the screen
struct PermissionWarningBanner: View {
    @ObservedObject var permissionsChecker: SystemPermissionsChecker
    @State private var isDismissed = false
    
    var body: some View {
        if permissionsChecker.hasWarnings && !isDismissed {
            VStack(spacing: 0) {
                ForEach(permissionsChecker.warningMessages) { warning in
                    warningRow(warning)
                }
            }
        }
    }
    
    @ViewBuilder
    private func warningRow(_ warning: PermissionWarning) -> some View {
        HStack(spacing: 12) {
            Image(systemName: warning.icon)
                .foregroundColor(colorForSeverity(warning.severity))
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(warning.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(warning.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if warning.action == .openSettings {
                Button("Settings") {
                    openSettings()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            Button {
                withAnimation {
                    isDismissed = true
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(backgroundForSeverity(warning.severity))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.secondary.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    private func colorForSeverity(_ severity: PermissionWarning.Severity) -> Color {
        switch severity {
        case .critical: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
    
    private func backgroundForSeverity(_ severity: PermissionWarning.Severity) -> Color {
        switch severity {
        case .critical: return Color.red.opacity(0.1)
        case .warning: return Color.orange.opacity(0.1)
        case .info: return Color.blue.opacity(0.1)
        }
    }
    
    private func openSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preferences.icloud") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
}

/// Compact version for settings view - standalone version
struct PermissionStatusCardForSettings: View {
    @StateObject private var permissionsChecker = SystemPermissionsChecker.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            statusRow(
                title: "iCloud",
                isAvailable: permissionsChecker.iCloudAvailable,
                description: "Required for sync and backups"
            )
            
            statusRow(
                title: "CloudKit",
                isAvailable: permissionsChecker.cloudKitAvailable,
                description: "Syncs data across devices"
            )
            
            statusRow(
                title: "Storage Access",
                isAvailable: permissionsChecker.documentsAccessible,
                description: "Required for local backups"
            )
            
            if let lastCheck = permissionsChecker.lastCheckDate {
                HStack {
                    Text("Last checked:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lastCheck, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            
            Button {
                Task {
                    await permissionsChecker.checkAllPermissions()
                }
            } label: {
                Label("Refresh Status", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)
        }
        .padding()
        #if os(iOS)
        .background(Color(.secondarySystemGroupedBackground))
        #else
        .background(Color(nsColor: .controlBackgroundColor))
        #endif
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func statusRow(title: String, isAvailable: Bool, description: String) -> some View {
        HStack {
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isAvailable ? .green : .red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

/// Compact version for settings view
struct PermissionStatusCard: View {
    @ObservedObject var permissionsChecker: SystemPermissionsChecker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("System Status")
                .font(.headline)
            
            statusRow(
                title: "iCloud",
                isAvailable: permissionsChecker.iCloudAvailable,
                description: "Required for sync and backups"
            )
            
            statusRow(
                title: "CloudKit",
                isAvailable: permissionsChecker.cloudKitAvailable,
                description: "Syncs data across devices"
            )
            
            statusRow(
                title: "Storage Access",
                isAvailable: permissionsChecker.documentsAccessible,
                description: "Required for local backups"
            )
            
            if let lastCheck = permissionsChecker.lastCheckDate {
                HStack {
                    Text("Last checked:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lastCheck, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button {
                Task {
                    await permissionsChecker.checkAllPermissions()
                }
            } label: {
                Label("Refresh Status", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    @ViewBuilder
    private func statusRow(title: String, isAvailable: Bool, description: String) -> some View {
        HStack {
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isAvailable ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview("Warning Banner") {
    let checker = SystemPermissionsChecker.shared
    checker.hasWarnings = true
    checker.warningMessages = [
        PermissionWarning(
            id: "test",
            severity: .warning,
            title: "iCloud Not Available",
            message: "Please sign in to iCloud to enable sync",
            action: .openSettings
        )
    ]
    
    return PermissionWarningBanner(permissionsChecker: checker)
}

#Preview("Status Card") {
    let checker = SystemPermissionsChecker.shared
    checker.iCloudAvailable = true
    checker.cloudKitAvailable = false
    checker.documentsAccessible = true
    checker.lastCheckDate = Date()
    
    return PermissionStatusCard(permissionsChecker: checker)
        .padding()
}
#Preview("Settings Card") {
    PermissionStatusCardForSettings()
        .padding()
}


