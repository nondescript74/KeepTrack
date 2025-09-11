//
//  CommonStore.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 4/10/25.
//

import Foundation
import OSLog
import SwiftUI

/// `CommonStore` is an observable store that loads and persists `CommonEntry` history.
/// 
/// IMPORTANT: Clients should use the async initializer `await CommonStore.loadStore()`
/// to obtain a fully loaded instance before accessing or mutating `history`.
///
/// Example:
/// ```swift
/// let store = await CommonStore.loadStore()
/// ```
///
/// Accessing or mutating `history` before calling `loadHistory()` will result in empty or incomplete data.
@MainActor
@Observable final class CommonStore {

    // MARK: - Async initializer
    /// Loads CommonStore and waits for history to finish loading before using.
    static func loadStore() async -> CommonStore {
        let store = CommonStore()
        await store.loadHistory()
        return store
    }

    // MARK: - Properties

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CommonStore")
    private static let storeFilename = "entrystore.json"
    private let fileURL: URL

    var history: [CommonEntry] = []

    // MARK: - Init

    /// Internal use only. Use `await CommonStore.loadStore()` to get a fully loaded instance.
    init() {
        // Use App Group container for shared storage between app and intents
        // TODO: Replace with your real App Group identifier
        let appGroupID = "group.com.headydiscy.KeepTrack"
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            self.fileURL = containerURL.appendingPathComponent(Self.storeFilename)
        } else {
            self.fileURL = URL(fileURLWithPath: "/dev/null")
            logger.fault("Failed to resolve App Group container directory")
            fatalError("can't resolve App Group container directory")
        }

        // For SwiftUI Environment-based usage, trigger loading history here,
        // but callers requiring strong load guarantees (e.g. intent/shortcut usages)
        // should still use `await CommonStore.loadStore()`.
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

    @MainActor
    func saveAndWait() async {
        await self.save()
    }

    // MARK: - CRUD
    @MainActor
    func addEntry(entry: CommonEntry) async {
        self.history.append(entry)
        self.logger.info("CStore: Added entry to CommonStore \(entry.name)")
        await self.save()
    }

    @MainActor
    func removeEntryAtId(uuid: UUID) async {
        self.history.removeAll { $0.id == uuid }
        self.logger.info("CStore: Removed entry with id \(uuid)")
        await self.save()
    }

    func getTodaysIntake() -> [CommonEntry] {
        let todays = self.history.filter { Calendar.autoupdatingCurrent.isDateInToday($0.date) }
        self.logger.info("CStore: Found \(todays.count) entries for today")
        return todays
    }
}

