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
                    .background(Color(.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Diagnostic Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            }
            .task {
                await loadLogs()
            }
            .sheet(isPresented: $showShareSheet) {
                if let shareURL {
                    ShareSheet(items: [shareURL])
                }
            }
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

// Share sheet wrapper for UIKit's UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    DiagnosticLogView()
}
