//
//  CommonStore.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation
import OSLog
import SwiftUI

@MainActor
@Observable final class CommonStore {

    // MARK: - Properties

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CommonStore")
    private static let storeFilename = "entrystore.json"
    private let fileURL: URL

    var history: [CommonEntry] = []

    // MARK: - Init

    init() {
        // Find the documents directory and file URL
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let docDirUrl = urls.first {
            self.fileURL = docDirUrl.appendingPathComponent(Self.storeFilename)
        } else {
            self.fileURL = URL(fileURLWithPath: "/dev/null")
            logger.fault("Failed to resolve document directory")
        }

        Task { await self.loadHistory() }
    }

    // MARK: - Persistence (async)

    func loadHistory() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                if FileManager.default.fileExists(atPath: self.fileURL.path) {
                    do {
                        let data = try Data(contentsOf: self.fileURL)
                        if data.isEmpty {
                            Task { @MainActor in
                                self.history = []
                                self.logger.info("CStore: entrystore.json file is empty")
                                continuation.resume()
                            }
                        } else {
                            let loadedHistory = try JSONDecoder().decode([CommonEntry].self, from: data)
                            Task { @MainActor in
                                self.history = loadedHistory.sorted { $0.date > $1.date }
                                self.logger.info("CStore: loaded \(self.history.count) entries")
                                continuation.resume()
                            }
                        }
                    } catch {
                        Task { @MainActor in
                            self.logger.error("CStore: Couldn't read history: \(error.localizedDescription)")
                            self.history = []
                            continuation.resume()
                        }
                    }
                } else {
                    // Create the file if it doesn't exist
                    FileManager.default.createFile(atPath: self.fileURL.path, contents: nil)
                    Task { @MainActor in
                        self.logger.info("CStore: Created file \(Self.storeFilename)")
                        self.history = []
                        continuation.resume()
                    }
                }
            }
        }
    }

    func save() async {
        let entries = self.history.sorted { $0.date > $1.date }
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                do {
                    let data = try JSONEncoder().encode(entries)
                    try data.write(to: self.fileURL, options: [.atomic])
                    Task { @MainActor in
                        self.logger.info("CStore: Saved history to file")
                        self.history = entries
                        continuation.resume()
                    }
                } catch {
                    Task { @MainActor in
                        self.logger.error("CStore: Couldn't save history file: \(error.localizedDescription)")
                        continuation.resume()
                    }
                }
            }
        }
    }

    // MARK: - CRUD

    func addEntry(entry: CommonEntry) {
        self.history.append(entry)
        self.logger.info("CStore: Added entry to CommonStore \(entry.name)")
        Task { await self.save() }
    }

    func removeEntryAtId(uuid: UUID) {
        self.history.removeAll { $0.id == uuid }
        self.logger.info("CStore: Removed entry with id \(uuid)")
        Task { await self.save() }
    }

    func getTodaysIntake() -> [CommonEntry] {
        let todays = self.history.filter { Calendar.autoupdatingCurrent.isDateInToday($0.date) }
        self.logger.info("CStore: Found \(todays.count) entries for today")
        return todays
    }
}
