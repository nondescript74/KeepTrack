//
//  LicenseView.swift
//  KeepTrack
//
//  Created on 11/13/25.
//

import SwiftUI

struct LicenseView: View {
    let licenseManager: LicenseManager
    let onAccept: () -> Void
    
    @State private var hasScrolledToBottom = false
    @State private var licenseText: String = ""
    @State private var scrollPosition = ScrollPosition(edge: .top)
    @State private var showingHelp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("License Agreement")
                        .font(.title.bold())
                    Text("Version \(licenseManager.currentAppVersion)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingHelp = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.blue)
                        }
                        .accessibilityLabel("Show help for License")
                    }
                }
                
                Divider()
                
                // License text in scrollable view
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(licenseText.isEmpty ? "Loading license..." : licenseText)
                            .font(.body)
                            .textSelection(.enabled)
                            .padding()
                        
                        // Bottom spacer
                        Color.clear
                            .frame(height: 1)
                    }
                }
                .scrollPosition($scrollPosition)
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    // Check if we're near the bottom (within 50 points)
                    let contentHeight = geometry.contentSize.height
                    let containerHeight = geometry.containerSize.height
                    let offset = geometry.contentOffset.y
                    
                    // User has scrolled to bottom when: offset + containerHeight >= contentHeight
                    return (offset + containerHeight) >= (contentHeight - 50)
                } action: { oldValue, newValue in
                    if newValue && !hasScrolledToBottom {
                        hasScrolledToBottom = true
                    }
                }
                .background(Color(.systemGroupedBackground))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                
                // Accept button
                VStack(spacing: 12) {
                    if !hasScrolledToBottom {
                        Text("Please scroll to the bottom to continue")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button {
                        onAccept()
                    } label: {
                        Text("I Accept")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasScrolledToBottom ? Color.accentColor : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!hasScrolledToBottom)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(.ultraThinMaterial)
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            loadLicense()
        }
        .sheet(isPresented: $showingHelp) {
            HelpView(topic: HelpContentManager.getHelpTopic(for: .license))
        }
    }
    
    private func loadLicense() {
        if let url = Bundle.main.url(forResource: "License", withExtension: "md"),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            licenseText = content
        } else {
            // Fallback license text
            licenseText = """
            END USER LICENSE AGREEMENT
            
            Last Updated: \(Date.now.formatted(date: .long, time: .omitted))
            
            PLEASE READ THIS LICENSE AGREEMENT CAREFULLY BEFORE USING THIS APPLICATION.
            
            By using KeepTrack, you agree to be bound by the terms of this License Agreement. If you do not agree to the terms of this License Agreement, do not use this application.
            
            1. LICENSE GRANT
            Subject to the terms of this Agreement, you are granted a limited, non-exclusive, non-transferable license to use this application.
            
            2. RESTRICTIONS
            You may not copy, modify, distribute, sell, or lease any part of this application.
            
            3. DATA AND PRIVACY
            This application may collect and store personal health data on your device. This data remains on your device and is not transmitted to external servers.
            
            4. DISCLAIMER OF WARRANTIES
            This application is provided "as is" without warranty of any kind, either express or implied.
            
            5. LIMITATION OF LIABILITY
            In no event shall the developers be liable for any damages arising out of the use or inability to use this application.
            
            6. CHANGES TO THIS AGREEMENT
            This agreement may be updated from time to time. Continued use of the application after changes constitutes acceptance of the new terms.
            
            By clicking "I Accept," you acknowledge that you have read and understood this agreement and agree to be bound by its terms.
            """
        }
    }
}

#Preview {
    LicenseView(licenseManager: LicenseManager()) {
        print("License accepted")
    }
}
