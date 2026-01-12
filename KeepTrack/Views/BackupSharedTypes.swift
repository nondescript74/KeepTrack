//
//  BackupSharedTypes.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Alert Message

struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

// MARK: - Backup Document

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Cloud Sync Status

enum CloudSyncStatus {
    case syncing
    case synced
    case error
    case disabled
    case unknown
}
