//
//  DiagnosticLogManager.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 12/24/25.
//

import Foundation
import OSLog
import UIKit

/// Manager for collecting and exporting diagnostic logs
@MainActor
@Observable
class DiagnosticLogManager {
    static let shared = DiagnosticLogManager()
    
    private let subsystem = Bundle.main.bundleIdentifier ?? "KeepTrack"
    
    private init() {}
    
    /// Collects all logs from the app's subsystem
    func collectLogs(since: Date = Date().addingTimeInterval(-86400)) async throws -> String {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let position = store.position(date: since)
        
        let entries = try store.getEntries(at: position, matching: NSPredicate(format: "subsystem == %@", subsystem))
        
        var logText = "KeepTrack Diagnostic Log\n"
        logText += "Generated: \(Date().formatted(date: .complete, time: .complete))\n"
        logText += "App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")\n"
        logText += "Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")\n"
        logText += "Device: \(UIDevice.current.model)\n"
        logText += "iOS Version: \(UIDevice.current.systemVersion)\n"
        logText += "---\n\n"
        
        for entry in entries {
            if let logEntry = entry as? OSLogEntryLog {
                let timestamp = logEntry.date.formatted(date: .omitted, time: .standard)
                let level = levelString(for: logEntry.level)
                let category = logEntry.category
                let message = logEntry.composedMessage
                
                logText += "[\(timestamp)] [\(level)] [\(category)] \(message)\n"
            }
        }
        
        return logText
    }
    
    private func levelString(for level: OSLogEntryLog.Level) -> String {
        switch level {
        case .undefined:
            return "UNDEFINED"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .notice:
            return "NOTICE"
        case .error:
            return "ERROR"
        case .fault:
            return "FAULT"
        @unknown default:
            return "UNKNOWN"
        }
    }
    
    /// Export logs as a shareable file
    func exportLogs(since: Date = Date().addingTimeInterval(-86400)) async throws -> URL {
        let logText = try await collectLogs(since: since)
        
        let fileName = "KeepTrack_Log_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).txt"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try logText.write(to: fileURL, atomically: true, encoding: .utf8)
        
        return fileURL
    }
}
