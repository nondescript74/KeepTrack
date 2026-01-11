//
//  SettingsView.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 12/24/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showDiagnosticLog = false
    @State private var showReminderTestingHelp = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Help & Support") {
                    Button {
                        showReminderTestingHelp = true
                    } label: {
                        HStack {
                            Label("Reminder Testing Guide", systemImage: "bell.badge.circle")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button {
                        showDiagnosticLog = true
                    } label: {
                        HStack {
                            Label("Diagnostic Log", systemImage: "doc.text.magnifyingglass")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showDiagnosticLog) {
                DiagnosticLogView()
            }
            .sheet(isPresented: $showReminderTestingHelp) {
                HelpView(topic: HelpContentManager.getHelpTopic(for: .reminderTesting))
            }
        }
    }
}

#Preview {
    SettingsView()
}
