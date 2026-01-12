//
//  BackupHistoryView.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

/// Shows history of backup files
struct BackupHistoryView: View {
    @State private var backupFiles: [BackupFileInfo] = []
    @State private var isLoading = true
    @State private var selectedBackup: BackupFileInfo?
    @State private var showingShareSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading backups...")
            } else if backupFiles.isEmpty {
                ContentUnavailableView(
                    "No Backups",
                    systemImage: "tray",
                    description: Text("Automatic backups will appear here when enabled.")
                )
            } else {
                List {
                    ForEach(backupFiles) { backup in
                        BackupFileRow(backup: backup)
                            .contextMenu {
                                Button {
                                    selectedBackup = backup
                                    showingShareSheet = true
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                
                                Button(role: .destructive) {
                                    selectedBackup = backup
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    selectedBackup = backup
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle("Backup History")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await loadBackupFiles()
        }
        .refreshable {
            await loadBackupFiles()
        }
        #if os(iOS)
        .sheet(isPresented: $showingShareSheet) {
            if let backup = selectedBackup {
                ShareSheet_VBHV(items: [backup.url])
            }
        }
        #else
        .popover(isPresented: $showingShareSheet) {
            if let backup = selectedBackup {
                ShareSheet_VBHV(items: [backup.url])
                    .frame(width: 300, height: 400)
            }
        }
        #endif
        .alert("Delete Backup", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let backup = selectedBackup {
                    deleteBackup(backup)
                }
            }
        } message: {
            Text("Are you sure you want to delete this backup? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func loadBackupFiles() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "Could not access documents directory."
            showingError = true
            return
        }
        
        let backupsDir = documentsURL.appendingPathComponent("Backups")
        
        // Ensure the directory exists
        if !FileManager.default.fileExists(atPath: backupsDir.path) {
            backupFiles = []
            return
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: backupsDir,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: [.skipsHiddenFiles]
            )
            .filter { $0.pathExtension == "json" }
            
            var files: [BackupFileInfo] = []
            for url in fileURLs {
                let resources = try url.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
                let info = BackupFileInfo(
                    id: UUID(),
                    url: url,
                    name: url.lastPathComponent,
                    creationDate: resources.creationDate ?? Date(),
                    fileSize: Int64(resources.fileSize ?? 0)
                )
                files.append(info)
            }
            
            backupFiles = files.sorted { $0.creationDate > $1.creationDate }
        } catch {
            errorMessage = "Failed to load backup files: \(error.localizedDescription)"
            showingError = true
            backupFiles = []
        }
    }
    
    private func deleteBackup(_ backup: BackupFileInfo) {
        do {
            try FileManager.default.removeItem(at: backup.url)
            Task {
                await loadBackupFiles()
            }
        } catch {
            errorMessage = "Failed to delete backup: \(error.localizedDescription)"
            showingError = true
        }
    }
}

// MARK: - Backup File Row

struct BackupFileRow: View {
    let backup: BackupFileInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: backup.isAutomatic ? "clock.arrow.circlepath" : "square.and.arrow.up")
                    .foregroundStyle(backup.isAutomatic ? .blue : .green)
                
                Text(backup.displayName)
                    .font(.headline)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Label(backup.creationDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label(backup.formattedFileSize, systemImage: "internaldrive")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Supporting Types

struct BackupFileInfo: Identifiable {
    let id: UUID
    let url: URL
    let name: String
    let creationDate: Date
    let fileSize: Int64
    
    var displayName: String {
        name.replacingOccurrences(of: "KeepTrack-Backup-", with: "")
            .replacingOccurrences(of: "AutoBackup-", with: "Auto ")
            .replacingOccurrences(of: ".json", with: "")
    }
    
    var isAutomatic: Bool {
        name.contains("AutoBackup")
    }
    
    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}

// MARK: - Share Sheet

#if os(macOS)
struct ShareSheet_VBHV: View {
    let items: [Any]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Share Backup")
                .font(.headline)
            
            ShareLink(item: items.first as! URL) {
                Label("Share File", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 250)
    }
}
#else
struct ShareSheet_VBHV: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIActivityViewController
    
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

// MARK: - Preview

#Preview {
    NavigationStack {
        BackupHistoryView()
    }
}
