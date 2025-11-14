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
    /// - Parameter storage: Optional storage backend. Defaults to AppGroupStorage for production use.
    static func loadStore(storage: CommonStoreStorage? = nil) async -> CommonStore {
        let store = CommonStore(storage: storage)
        await store.loadHistory()
        return store
    }

    // MARK: - Properties

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "CommonStore")
    private let storage: CommonStoreStorage

    var history: [CommonEntry] = []

    // MARK: - Init

    /// Internal use only. Use `await CommonStore.loadStore()` to get a fully loaded instance.
    /// - Parameter storage: Optional storage backend. Defaults to AppGroupStorage for production use.
    init(storage: CommonStoreStorage? = nil) {
        if let storage = storage {
            self.storage = storage
        } else {
            // Production default: use App Group storage
            do {
                self.storage = try AppGroupStorage()
            } catch {
                logger.fault("Failed to initialize AppGroupStorage: \(error.localizedDescription)")
                fatalError("Failed to initialize AppGroupStorage: \(error)")
            }
        }

        // For SwiftUI Environment-based usage, trigger loading history here,
        // but callers requiring strong load guarantees (e.g. intent/shortcut usages)
        // should still use `await CommonStore.loadStore()`.
        Task { await self.loadHistory() }
    }

    // MARK: - Persistence (async)

    func loadHistory() async {
        do {
            let loadedEntries = try await storage.load()
            self.history = loadedEntries.sorted { $0.date > $1.date }
            logger.info("CStore: loaded \(self.history.count) entries")
        } catch {
            logger.error("CStore: Couldn't read history: \(error.localizedDescription)")
            self.history = []
        }
    }

    func save() async {
        let entries = self.history.sorted { $0.date > $1.date }
        do {
            try await storage.save(entries)
            self.history = entries
            logger.info("CStore: Saved history")
        } catch {
            logger.error("CStore: Couldn't save history: \(error.localizedDescription)")
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

