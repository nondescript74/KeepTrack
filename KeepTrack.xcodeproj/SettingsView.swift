//
//  SettingsView.swift
//  KeepTrack
//
//  Created on 12/27/25.
//

import SwiftUI
import OSLog

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingLicense = false
    @State private var showingLogViewer = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - App Information
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Build", systemImage: "hammer")
                        Spacer()
                        Text(buildNumber)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("App Information")
                }
                
                // MARK: - Legal
                Section {
                    Button {
                        showingLicense = true
                    } label: {
                        Label("License Agreement", systemImage: "doc.text")
                    }
                } header: {
                    Text("Legal")
                }
                
                // MARK: - Diagnostics
                Section {
                    Button {
                        showingLogViewer = true
                    } label: {
                        Label("View Logs", systemImage: "list.bullet.rectangle")
                    }
                    
                    Button {
                        shareDiagnostics()
                    } label: {
                        Label("Export Diagnostics", systemImage: "square.and.arrow.up")
                    }
                } header: {
                    Text("Diagnostics")
                } footer: {
                    Text("View app logs or export diagnostic information for troubleshooting.")
                }
                
                // MARK: - Data
                Section {
                    NavigationLink {
                        DataManagementView()
                    } label: {
                        Label("Data Management", systemImage: "folder")
                    }
                } header: {
                    Text("Data")
                }
                
                // MARK: - About
                Section {
                    HStack {
                        Label("App Name", systemImage: "app.fill")
                        Spacer()
                        Text("KeepTrack")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Bundle ID", systemImage: "number")
                        Spacer()
                        Text(bundleIdentifier)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingLicense) {
                LicenseView(licenseManager: LicenseManager(), viewMode: .viewing)
            }
            .sheet(isPresented: $showingLogViewer) {
                LogViewerView()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    private var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "Unknown"
    }
    
    // MARK: - Helper Functions
    
    private func shareDiagnostics() {
        // Collect diagnostic information
        let diagnosticInfo = """
        KeepTrack Diagnostics
        =====================
        
        App Version: \(appVersion)
        Build: \(buildNumber)
        Bundle ID: \(bundleIdentifier)
        
        Device Information:
        - Device Model: \(UIDevice.current.model)
        - System Name: \(UIDevice.current.systemName)
        - System Version: \(UIDevice.current.systemVersion)
        
        Date: \(Date.now.formatted(date: .complete, time: .complete))
        
        --- Recent Logs ---
        (See Log Viewer for detailed logs)
        """
        
        // Create a temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("KeepTrack_Diagnostics.txt")
        
        do {
            try diagnosticInfo.write(to: tempURL, atomically: true, encoding: .utf8)
            
            // Present share sheet
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            print("Failed to export diagnostics: \(error)")
        }
    }
}

// MARK: - Data Management View

struct DataManagementView: View {
    @State private var showingResetAlert = false
    @State private var dataSize: String = "Calculating..."
    
    var body: some View {
        List {
            Section {
                HStack {
                    Label("Data Size", systemImage: "externaldrive")
                    Spacer()
                    Text(dataSize)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Storage")
            }
            
            Section {
                Button(role: .destructive) {
                    showingResetAlert = true
                } label: {
                    Label("Reset All Data", systemImage: "trash")
                        .foregroundColor(.red)
                }
            } header: {
                Text("Danger Zone")
            } footer: {
                Text("This will permanently delete all your intake history and goals. This action cannot be undone.")
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            calculateDataSize()
        }
        .alert("Reset All Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will permanently delete all your intake history and goals. This action cannot be undone.")
        }
    }
    
    private func calculateDataSize() {
        // Calculate the size of app data
        let appGroupID = "group.com.headydiscy.KeepTrack"
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            do {
                let resourceKeys: [URLResourceKey] = [.fileSizeKey, .isDirectoryKey]
                let enumerator = FileManager.default.enumerator(
                    at: containerURL,
                    includingPropertiesForKeys: resourceKeys,
                    options: []
                )
                
                var totalSize: Int64 = 0
                
                while let fileURL = enumerator?.nextObject() as? URL {
                    let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                    if let fileSize = resourceValues.fileSize, resourceValues.isDirectory == false {
                        totalSize += Int64(fileSize)
                    }
                }
                
                dataSize = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
            } catch {
                dataSize = "Unable to calculate"
            }
        } else {
            dataSize = "Unknown"
        }
    }
    
    private func resetAllData() {
        // This would need to be implemented based on your data storage
        // For now, it's a placeholder
        let appGroupID = "group.com.headydiscy.KeepTrack"
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            do {
                let contents = try FileManager.default.contentsOfDirectory(
                    at: containerURL,
                    includingPropertiesForKeys: nil
                )
                
                for fileURL in contents {
                    try FileManager.default.removeItem(at: fileURL)
                }
            } catch {
                print("Failed to reset data: \(error)")
            }
        }
    }
}

// MARK: - Log Viewer View

struct LogViewerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var logEntries: [LogEntry] = []
    @State private var isLoading = true
    @State private var filterLevel: LogLevel = .all
    @State private var searchText = ""
    
    enum LogLevel: String, CaseIterable {
        case all = "All"
        case debug = "Debug"
        case info = "Info"
        case notice = "Notice"
        case error = "Error"
        case fault = "Fault"
    }
    
    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let level: LogLevel
        let category: String
        let message: String
    }
    
    var filteredLogs: [LogEntry] {
        logEntries.filter { entry in
            let matchesFilter = filterLevel == .all || entry.level == filterLevel
            let matchesSearch = searchText.isEmpty || 
                entry.message.localizedCaseInsensitiveContains(searchText) ||
                entry.category.localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading logs...")
                } else if logEntries.isEmpty {
                    ContentUnavailableView(
                        "No Logs Available",
                        systemImage: "list.bullet.rectangle",
                        description: Text("No log entries found. Start using the app to generate logs.")
                    )
                } else {
                    List {
                        ForEach(filteredLogs) { entry in
                            LogEntryRow(entry: entry)
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search logs")
                }
            }
            .navigationTitle("Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Filter", selection: $filterLevel) {
                            ForEach(LogLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        exportLogs()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .task {
                await fetchLogs()
            }
        }
    }
    
    private func fetchLogs() async {
        isLoading = true
        
        do {
            // Use OSLogStore to fetch logs
            let logStore = try OSLogStore(scope: .currentProcessIdentifier)
            let position = logStore.position(timeIntervalSinceLatestBoot: -3600) // Last hour
            
            let entries = try logStore.getEntries(at: position)
                .compactMap { entry -> LogEntry? in
                    guard let logEntry = entry as? OSLogEntryLog else { return nil }
                    
                    let level: LogLevel = {
                        switch logEntry.level {
                        case .debug: return .debug
                        case .info: return .info
                        case .notice: return .notice
                        case .error: return .error
                        case .fault: return .fault
                        default: return .info
                        }
                    }()
                    
                    return LogEntry(
                        timestamp: logEntry.date,
                        level: level,
                        category: logEntry.category,
                        message: logEntry.composedMessage
                    )
                }
            
            logEntries = Array(entries)
        } catch {
            print("Failed to fetch logs: \(error)")
            logEntries = []
        }
        
        isLoading = false
    }
    
    private func exportLogs() {
        let logText = filteredLogs.map { entry in
            "[\(entry.timestamp.formatted(date: .abbreviated, time: .standard))] [\(entry.level.rawValue.uppercased())] [\(entry.category)] \(entry.message)"
        }.joined(separator: "\n")
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("KeepTrack_Logs.txt")
        
        do {
            try logText.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            print("Failed to export logs: \(error)")
        }
    }
}

// MARK: - Log Entry Row

struct LogEntryRow: View {
    let entry: LogViewerView.LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: levelIcon)
                    .foregroundStyle(levelColor)
                    .font(.caption)
                
                Text(entry.timestamp.formatted(date: .abbreviated, time: .standard))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(entry.category)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Text(entry.message)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
    
    private var levelIcon: String {
        switch entry.level {
        case .debug: return "ant.fill"
        case .info: return "info.circle.fill"
        case .notice: return "bell.fill"
        case .error: return "exclamationmark.triangle.fill"
        case .fault: return "xmark.octagon.fill"
        case .all: return "circle.fill"
        }
    }
    
    private var levelColor: Color {
        switch entry.level {
        case .debug: return .secondary
        case .info: return .blue
        case .notice: return .cyan
        case .error: return .orange
        case .fault: return .red
        case .all: return .primary
        }
    }
}

// MARK: - Preview

#Preview("Settings View") {
    SettingsView()
}

#Preview("Log Viewer") {
    LogViewerView()
}

#Preview("Data Management") {
    NavigationStack {
        DataManagementView()
    }
}
