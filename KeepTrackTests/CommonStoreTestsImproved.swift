//
//  CommonStoreTestsImproved.swift
//  KeepTrackTests
//
//  Created on 11/13/25.
//

import Foundation
import Testing
@testable import KeepTrack

/// Comprehensive test suite for CommonStore using dependency injection
/// 
/// This test suite provides complete coverage of CommonStore functionality using
/// InMemoryStorage for complete test isolation. These tests are fast, reliable,
/// and have no race conditions or file system dependencies.
///
/// Coverage includes:
/// - Empty store loading
/// - Adding single and multiple entries
/// - Removing entries by ID
/// - Handling nonexistent entry removal
/// - Duplicate entry names with unique IDs
/// - Persistence across store reloads
/// - History sorting by date (descending)
/// - Today's intake filtering
///
/// All tests use dependency injection via `CommonStore.loadStore(storage:)`
/// to ensure complete isolation between test runs.
@Suite("CommonStore Tests (Improved with DI)")
struct CommonStoreTestsImproved {
    
    // Helper to create test entries
    func makeEntry(name: String, amount: Double, date: Date = .now, units: String = "mg", goalMet: Bool = false) -> CommonEntry {
        CommonEntry(id: UUID(), date: date, units: units, amount: amount, name: name, goalMet: goalMet)
    }
    
    @Test("Loads an empty store successfully")
    func loadEmptyStore() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let isEmpty = await MainActor.run { store.history.isEmpty }
        #expect(isEmpty, "History should be empty on first load")
    }
    
    @Test("Adds and persists an entry")
    func addEntry() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let entry = makeEntry(name: "Test Entry", amount: 1)
        await store.addEntry(entry: entry)
        
        let hasEntry = await MainActor.run { 
            store.history.contains(where: { $0.name == "Test Entry" }) 
        }
        #expect(hasEntry, "Entry 'Test Entry' should exist after adding")
        
        // Verify it was actually saved to storage
        let savedEntries = try await storage.load()
        #expect(savedEntries.count == 1, "Storage should contain 1 entry")
        #expect(savedEntries.first?.name == "Test Entry", "Saved entry should match")
    }

    @Test("Removes an entry by ID")
    func removeEntryById() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let entry = makeEntry(name: "Test Entry", amount: 1)
        await store.addEntry(entry: entry)
        
        let existsBefore = await MainActor.run { 
            store.history.contains(where: { $0.id == entry.id }) 
        }
        #expect(existsBefore, "Entry should exist before removal")
        
        await store.removeEntryAtId(uuid: entry.id)
        
        let existsAfter = await MainActor.run { 
            store.history.contains(where: { $0.id == entry.id }) 
        }
        #expect(!existsAfter, "Entry should not exist after removal")
        
        // Verify it was removed from storage
        let savedEntries = try await storage.load()
        #expect(savedEntries.isEmpty, "Storage should be empty after removal")
    }
    
    @Test("Adds multiple entries")
    func addMultipleEntries() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let entry1 = makeEntry(name: "Entry 1", amount: 10, goalMet: true)
        let entry2 = makeEntry(name: "Entry 2", amount: 20, goalMet: false)
        
        await store.addEntry(entry: entry1)
        await store.addEntry(entry: entry2)
        
        let bothExist = await MainActor.run { 
            [entry1, entry2].allSatisfy { entry in 
                store.history.contains(where: { $0.id == entry.id }) 
            } 
        }
        #expect(bothExist, "Both entries should exist in history")
        
        let savedEntries = try await storage.load()
        #expect(savedEntries.count == 2, "Storage should contain 2 entries")
    }

    @Test("Removing a nonexistent entry does not affect others")
    func removeNonexistentEntry() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let entry = makeEntry(name: "Real Entry", amount: 10, goalMet: true)
        await store.addEntry(entry: entry)
        
        let fakeID = UUID()
        await store.removeEntryAtId(uuid: fakeID)
        
        let stillThere = await MainActor.run { 
            store.history.contains(where: { $0.id == entry.id }) 
        }
        #expect(stillThere, "Existing entry should not be removed when a nonexistent ID is used")
        
        let savedEntries = try await storage.load()
        #expect(savedEntries.count == 1, "Storage should still contain the original entry")
    }

    @Test("Handles duplicate entry names with unique IDs")
    func duplicateEntriesDifferentIDs() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let entry1 = makeEntry(name: "Duplicate", amount: 10, goalMet: true)
        let entry2 = makeEntry(name: "Duplicate", amount: 20, goalMet: false)
        
        await store.addEntry(entry: entry1)
        await store.addEntry(entry: entry2)
        
        let bothThere = await MainActor.run { 
            store.history.filter { $0.name == "Duplicate" }.count == 2 
        }
        #expect(bothThere, "Both duplicate-named entries with different IDs should exist")
        
        await store.removeEntryAtId(uuid: entry1.id)
        
        let onlySecondLeft = await MainActor.run { 
            store.history.contains(where: { $0.id == entry2.id }) && 
            !store.history.contains(where: { $0.id == entry1.id }) 
        }
        #expect(onlySecondLeft, "First duplicate should be removable independently")
    }

    @Test("Persists history after store reload")
    func persistenceAfterReload() async throws {
        let storage = InMemoryStorage()
        let entry = makeEntry(name: "Persisted Entry", amount: 99, goalMet: true)
        
        // Create first store instance and add entry
        do {
            let store = await CommonStore.loadStore(storage: storage)
            await store.addEntry(entry: entry)
        }
        
        // Create new store instance with same storage
        let storeReloaded = await CommonStore.loadStore(storage: storage)
        
        let found = await MainActor.run { 
            storeReloaded.history.contains(where: { $0.id == entry.id }) 
        }
        #expect(found, "Entry should still exist after store reload")
    }
    
    @Test("History is sorted by date descending")
    func historySortedByDate() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let now = Date.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        let entry1 = makeEntry(name: "Yesterday", amount: 1, date: yesterday)
        let entry2 = makeEntry(name: "Tomorrow", amount: 2, date: tomorrow)
        let entry3 = makeEntry(name: "Today", amount: 3, date: now)
        
        // Add in random order
        await store.addEntry(entry: entry1)
        await store.addEntry(entry: entry2)
        await store.addEntry(entry: entry3)
        
        let history = await MainActor.run { store.history }
        
        // Should be sorted: tomorrow, today, yesterday
        #expect(history.count == 3)
        #expect(history[0].name == "Tomorrow", "First entry should be tomorrow")
        #expect(history[1].name == "Today", "Second entry should be today")
        #expect(history[2].name == "Yesterday", "Third entry should be yesterday")
    }
    
    @Test("getTodaysIntake returns only today's entries")
    func getTodaysIntake() async throws {
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let now = Date.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        
        let todayEntry = makeEntry(name: "Today", amount: 10, date: now)
        let yesterdayEntry = makeEntry(name: "Yesterday", amount: 20, date: yesterday)
        
        await store.addEntry(entry: todayEntry)
        await store.addEntry(entry: yesterdayEntry)
        
        let todaysIntake = await MainActor.run { store.getTodaysIntake() }
        
        #expect(todaysIntake.count == 1, "Should only return today's entries")
        #expect(todaysIntake.first?.name == "Today", "Should be the entry from today")
    }
}
