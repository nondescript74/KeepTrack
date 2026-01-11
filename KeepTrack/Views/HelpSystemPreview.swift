//
//  HelpSystemPreview.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 11/14/25.
//

import SwiftUI

/// A preview view to test all help content
struct HelpSystemPreview: View {
    @State private var selectedTopic: HelpViewIdentifier?
    
    var body: some View {
        NavigationStack {
            List {
                Section("App Views") {
                    HelpPreviewRow(
                        title: "Dashboard",
                        icon: "square.grid.2x2",
                        identifier: .dashboard,
                        selectedTopic: $selectedTopic
                    )
                    
                    HelpPreviewRow(
                        title: "Today",
                        icon: "clipboard",
                        identifier: .today,
                        selectedTopic: $selectedTopic
                    )
                    
                    HelpPreviewRow(
                        title: "Yesterday",
                        icon: "clipboard.fill",
                        identifier: .yesterday,
                        selectedTopic: $selectedTopic
                    )
                    
                    HelpPreviewRow(
                        title: "By Day & Time",
                        icon: "calendar.badge.clock",
                        identifier: .consumptionByDayAndTime,
                        selectedTopic: $selectedTopic
                    )
                }
                
                Section("History & Tracking") {
                    HelpPreviewRow(
                        title: "Add History",
                        icon: "heart.text.clipboard",
                        identifier: .addHistory,
                        selectedTopic: $selectedTopic
                    )
                    
                    HelpPreviewRow(
                        title: "Edit History",
                        icon: "square.and.pencil",
                        identifier: .editHistory,
                        selectedTopic: $selectedTopic
                    )
                }
                
                Section("Goals") {
                    HelpPreviewRow(
                        title: "Show Goals",
                        icon: "wineglass",
                        identifier: .showGoals,
                        selectedTopic: $selectedTopic
                    )
                    
                    HelpPreviewRow(
                        title: "Enter Goal",
                        icon: "microphone.badge.plus",
                        identifier: .enterGoal,
                        selectedTopic: $selectedTopic
                    )
                    
                    HelpPreviewRow(
                        title: "Edit Goals",
                        icon: "figure.hockey",
                        identifier: .editGoals,
                        selectedTopic: $selectedTopic
                    )
                }
                
                Section("Settings") {
                    HelpPreviewRow(
                        title: "Add Intake Type",
                        icon: "person",
                        identifier: .addIntakeType,
                        selectedTopic: $selectedTopic
                    )
                    
                    HelpPreviewRow(
                        title: "License",
                        icon: "doc.text",
                        identifier: .license,
                        selectedTopic: $selectedTopic
                    )
                }
                
                Section("Statistics") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Total Help Topics", systemImage: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("11 help topics available")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("All views have contextual help implemented")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Help System Preview")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedTopic) { identifier in
                HelpView(topic: HelpContentManager.getHelpTopic(for: identifier))
            }
        }
    }
}

/// A row in the help preview list
struct HelpPreviewRow: View {
    let title: String
    let icon: String
    let identifier: HelpViewIdentifier
    @Binding var selectedTopic: HelpViewIdentifier?
    
    var body: some View {
        Button {
            selectedTopic = identifier
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Text("Tap to preview help")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.blue)
            }
        }
    }
}

// Make HelpViewIdentifier Identifiable for sheet presentation
extension HelpViewIdentifier: Identifiable {
    var id: String {
        switch self {
        case .dashboard: return "dashboard"
        case .today: return "today"
        case .yesterday: return "yesterday"
        case .consumptionByDayAndTime: return "consumptionByDayAndTime"
        case .addHistory: return "addHistory"
        case .showGoals: return "showGoals"
        case .enterGoal: return "enterGoal"
        case .editHistory: return "editHistory"
        case .editGoals: return "editGoals"
        case .addIntakeType: return "addIntakeType"
        case .license: return "license"
        case .reminderTesting: return "reminderTesting"
        }
    }
}

#Preview {
    HelpSystemPreview()
}

#Preview("Help Row") {
    List {
        HelpPreviewRow(
            title: "Dashboard",
            icon: "square.grid.2x2",
            identifier: .dashboard,
            selectedTopic: .constant(nil)
        )
    }
}
