//
//  SwiftDataStore.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import SwiftData
import OSLog

/// SwiftData-based store that mirrors CommonStore functionality
/// Can be used as a drop-in replacement for CommonStore
@MainActor
@Observable final class SwiftDataStore {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KeepTrack", category: "SwiftDataStore")
    private let modelContext: ModelContext
    
    /// All entries, sorted by date (newest first)
    var history: [CommonEntry] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            await loadHistory()
        }
    }
    
    /// Convenience initializer using shared manager
    static func loadStore() async -> SwiftDataStore {
        let store = SwiftDataStore(modelContext: SwiftDataManager.shared.mainContext)
        await store.loadHistory()
        return store
    }
    
    // MARK: - Loading
    
    func loadHistory() async {
        do {
            let descriptor = FetchDescriptor<SDEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let entries = try modelContext.fetch(descriptor)
            self.history = entries.map { $0.toCommonEntry() }
            logger.info("SDStore: loaded \(self.history.count) entries from SwiftData")
        } catch {
            logger.error("SDStore: Couldn't read history: \(error.localizedDescription)")
            self.history = []
        }
    }
    
    // MARK: - CRUD
    
    func addEntry(entry: CommonEntry) async {
        let sdEntry = SDEntry(from: entry)
        modelContext.insert(sdEntry)
        
        do {
            try modelContext.save()
            await loadHistory() // Refresh
            logger.info("SDStore: Added entry \(entry.name)")
        } catch {
            logger.error("SDStore: Failed to save entry: \(error.localizedDescription)")
        }
    }
    
    func removeEntryAtId(uuid: UUID) async {
        do {
            let descriptor = FetchDescriptor<SDEntry>(
                predicate: #Predicate { $0.id == uuid }
            )
            let entries = try modelContext.fetch(descriptor)
            
            for entry in entries {
                modelContext.delete(entry)
            }
            
            try modelContext.save()
            await loadHistory() // Refresh
            logger.info("SDStore: Removed entry with id \(uuid)")
        } catch {
            logger.error("SDStore: Failed to remove entry: \(error.localizedDescription)")
        }
    }
    
    func getTodaysIntake() -> [CommonEntry] {
        let todays = self.history.filter { Calendar.autoupdatingCurrent.isDateInToday($0.date) }
        logger.info("SDStore: Found \(todays.count) entries for today")
        return todays
    }
    
    // MARK: - Querying
    
    /// Get entries for a specific date range
    func getEntries(from startDate: Date, to endDate: Date) async -> [CommonEntry] {
        do {
            let descriptor = FetchDescriptor<SDEntry>(
                predicate: #Predicate { entry in
                    entry.date >= startDate && entry.date <= endDate
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let entries = try modelContext.fetch(descriptor)
            return entries.map { $0.toCommonEntry() }
        } catch {
            logger.error("SDStore: Failed to fetch entries: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Get entries for a specific intake name
    func getEntries(forName name: String) async -> [CommonEntry] {
        do {
            let descriptor = FetchDescriptor<SDEntry>(
                predicate: #Predicate { entry in
                    entry.name == name
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let entries = try modelContext.fetch(descriptor)
            return entries.map { $0.toCommonEntry() }
        } catch {
            logger.error("SDStore: Failed to fetch entries: \(error.localizedDescription)")
            return []
        }
    }
}
