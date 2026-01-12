//
//  DiagnosticLogView.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 12/24/25.
//

import SwiftUI
import OSLog

struct DiagnosticLogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var logContent: String = ""
    @State private var isLoading = false
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    @State private var timeRange: TimeRange = .last24Hours
    @State private var errorMessage: String?
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case last5Minutes = "Last 5 Min"
        case last1Hour = "Last Hour"
        case last6Hours = "Last 6 Hours"
        case last24Hours = "Last 24 Hours"
        case last3Days = "Last 3 Days"
        case last7Days = "Last 7 Days"
        
        var id: String { rawValue }
        
        var timeInterval: TimeInterval {
            switch self {
            case .last5Minutes: return -300
            case .last1Hour: return -3600
            case .last6Hours: return -21600
            case .last24Hours: return -86400
            case .last3Days: return -259200
            case .last7Days: return -604800
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Time Range Picker
                Picker("Time Range", selection: $timeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: timeRange) { _, _ in
                    Task {
                        await loadLogs()
                    }
                }
                
                if let errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text("Error Loading Logs")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await loadLogs()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading logs...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        Text(logContent.isEmpty ? "No logs available for selected time range" : logContent)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    #if os(iOS)
                    .background(Color(.systemGroupedBackground))
                    #else
                    .background(Color(nsColor: .controlBackgroundColor))
                    #endif
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Diagnostic Log")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(macOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await exportLogs()
                        }
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .disabled(logContent.isEmpty || isLoading)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await loadLogs()
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
                #else
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await exportLogs()
                        }
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .disabled(logContent.isEmpty || isLoading)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await loadLogs()
                        }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
                #endif
            }
            .task {
                await loadLogs()
            }
            #if os(iOS)
            .sheet(isPresented: $showShareSheet) {
                if let shareURL {
                    ShareSheetMac(items: [shareURL])
                }
            }
            #else
            .sheet(isPresented: $showShareSheet) {
                if let shareURL {
                    ShareSheetMac(items: [shareURL])
                }
            }
            #endif
        }
    }
    
    @MainActor
    private func loadLogs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let since = Date().addingTimeInterval(timeRange.timeInterval)
            logContent = try await DiagnosticLogManager.shared.collectLogs(since: since)
        } catch {
            errorMessage = error.localizedDescription
            logContent = ""
        }
        
        isLoading = false
    }
    
    @MainActor
    private func exportLogs() async {
        isLoading = true
        
        do {
            let since = Date().addingTimeInterval(timeRange.timeInterval)
            shareURL = try await DiagnosticLogManager.shared.exportLogs(since: since)
            showShareSheet = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#if os(iOS)
// Share sheet wrapper for UIKit's UIActivityViewController
struct ShareSheetMac: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
// Share sheet wrapper for macOS NSSharingService
struct ShareSheetMac: View {
    let items: [Any]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.up")
                .font(.largeTitle)
                .foregroundStyle(.blue)
            
            Text("Export Logs")
                .font(.headline)
            
            Text("The log file has been prepared and is ready to share.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Share...") {
                    shareLogs()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    private func shareLogs() {
        guard !items.isEmpty else { return }
        let picker = NSSharingServicePicker(items: items)
        
        // Get the key window and show the picker
        if let window = NSApplication.shared.keyWindow,
           let contentView = window.contentView {
            picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
        }
    }
}
#endif

#Preview {
    DiagnosticLogView()
}
