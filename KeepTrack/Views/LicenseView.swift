//
//  LicenseView.swift
//  KeepTrack
//
//  Created on 11/13/25.
//

import SwiftUI

struct LicenseView: View {
    let licenseManager: LicenseManager
    let onAccept: (() -> Void)?
    let viewMode: ViewMode
    
    enum ViewMode {
        case acceptance  // Must accept to continue (initial launch)
        case viewing     // Just viewing from Settings (already accepted)
    }
    
    @State private var hasScrolledToBottom = false
    @State private var licenseText: String = ""
    @State private var scrollPosition = ScrollPosition(edge: .top)
    @State private var showingHelp = false
    @Environment(\.dismiss) private var dismiss
    
    // Convenience initializer for acceptance flow
    init(licenseManager: LicenseManager, onAccept: @escaping () -> Void) {
        self.licenseManager = licenseManager
        self.onAccept = onAccept
        self.viewMode = .acceptance
    }
    
    // Initializer for viewing from Settings
    init(licenseManager: LicenseManager, viewMode: ViewMode = .viewing) {
        self.licenseManager = licenseManager
        self.onAccept = nil
        self.viewMode = viewMode
    }
    
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
                    
                    // Show acceptance info if viewing from Settings
                    if viewMode == .viewing, let acceptanceInfo = licenseManager.acceptanceInfo {
                        Text(acceptanceInfo)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding()
                
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
                
                // Only show accept button in acceptance mode
                if viewMode == .acceptance {
                    Divider()
                    
                    // Accept button
                    VStack(spacing: 12) {
                        if !hasScrolledToBottom {
                            Text("Please scroll to the bottom to continue")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Button {
                            onAccept?()
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
                
                // Only show Done button when viewing from Settings
                if viewMode == .viewing {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(viewMode == .acceptance)
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
            Subject to the terms of this Agreement, you are granted a limited, non-exclusive, non-transferable license to use this application for personal purposes.
            
            2. RESTRICTIONS
            You may not copy, modify, distribute, sell, or lease any part of this application.
            
            3. DATA AND PRIVACY
            This application may collect and store personal health data including medication intake records, health goals, and tracking information. All data collected by this application is stored locally on your device and is not transmitted to external servers. You are responsible for backing up your data.
            
            4. HEALTH DISCLAIMER
            This application is designed to help you track your health-related activities. It is NOT a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.
            
            5. DISCLAIMER OF WARRANTIES
            This application is provided "as is" without warranty of any kind, either express or implied.
            
            6. LIMITATION OF LIABILITY
            In no event shall the developers be liable for any damages arising out of the use or inability to use this application, including but not limited to any loss of data or health information.
            
            7. UPDATES AND MODIFICATIONS
            This application may be updated from time to time. You may be required to accept a new version of this agreement to continue using updated versions.
            
            8. CHANGES TO THIS AGREEMENT
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
