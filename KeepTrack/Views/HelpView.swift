//
//  HelpView.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 11/14/25.
//

import SwiftUI

/// A view that displays help content for a specific screen
struct HelpView: View {
    let topic: HelpTopic
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.blue)
                            
                            Text(topic.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Text("Help & Guidance")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                    
                    // Sections
                    ForEach(topic.sections) { section in
                        HelpSectionView(section: section)
                    }
                    
                    // Footer
                    VStack(alignment: .leading, spacing: 8) {
                        Divider()
                        
                        Text("Still need help?")
                            .font(.headline)
                        
                        Text("If you have additional questions, please refer to the app documentation or contact support.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 16)
                }
                .padding()
            }
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(macOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
                #else
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
                #endif
            }
        }
    }
}

/// A view that displays a single help section
struct HelpSectionView: View {
    let section: HelpSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section title
            Label {
                Text(section.title)
                    .font(.title3)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "book.fill")
                    .foregroundStyle(.blue)
            }
            
            // Section content
            Text(section.content)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Tips if available
            if let tips = section.tips, !tips.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Tips", systemImage: "lightbulb.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(tips.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                                    .padding(.top, 2)
                                
                                Text(tips[index])
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.orange.opacity(0.1))
                }
            }
        }
    }
}

// MARK: - View Modifier for Help Button

/// A view modifier that adds a help button to any view
struct HelpButtonModifier: ViewModifier {
    let helpIdentifier: HelpViewIdentifier
    @State private var showingHelp = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                #if os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("Show help for this screen")
                }
                #else
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("Show help for this screen")
                }
                #endif
            }
            .sheet(isPresented: $showingHelp) {
                HelpView(topic: HelpContentManager.getHelpTopic(for: helpIdentifier))
            }
    }
}

// MARK: - View Extension

extension View {
    /// Adds a help button to the view's toolbar
    /// - Parameter identifier: The identifier for the help content to display
    /// - Returns: A view with a help button
    func helpButton(for identifier: HelpViewIdentifier) -> some View {
        self.modifier(HelpButtonModifier(helpIdentifier: identifier))
    }
}

// MARK: - Previews

#Preview("Help View - Dashboard") {
    HelpView(topic: HelpContentManager.getHelpTopic(for: .dashboard))
}

#Preview("Help View - Add Intake Type") {
    HelpView(topic: HelpContentManager.getHelpTopic(for: .addIntakeType))
}

#Preview("Help Section") {
    HelpSectionView(section: HelpSection(
        title: "Getting Started",
        content: "This is a sample help section that explains how to use a particular feature. It provides detailed information and context.",
        tips: [
            "This is the first tip",
            "Here's another helpful tip",
            "And one more useful suggestion"
        ]
    ))
    .padding()
}
