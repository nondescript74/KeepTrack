//
//  CommonStoreTests.swift
//  KeepTrackTests
//
//  Created by Zahirudeen Premji on 9/11/25.
//

import Foundation
import Testing
@testable import KeepTrack

func debugPrintHistory(_ history: [CommonEntry], label: String) {
    print("\n[DEBUG] \(label):")
    for entry in history {
        print("    id=\(entry.id), name=\(entry.name), date=\(entry.date), amount=\(entry.amount), goalMet=\(entry.goalMet)")
    }
}

// Helper to print the path being used for persistence
func debugPrintFileURL() {
    let appGroupID = "group.com.headydiscy.KeepTrack"
    let filename = "entrystore.json"
    if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
        let fileURL = containerURL.appendingPathComponent(filename)
        print("[DEBUG] Using fileURL: \(fileURL.path)")
    } else {
        print("[DEBUG] Failed to get App Group URL!")
    }
}

func clearCommonStoreFile() {
    let appGroupID = "group.com.headydiscy.KeepTrack"
    let filename = "entrystore.json"
    if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
        let fileURL = containerURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
}

@Suite("CommonStore Basic Integration")
struct CommonStoreTests {
    @Test("Loads an empty store successfully")
    func loadEmptyStore() async throws {
        clearCommonStoreFile()
        debugPrintFileURL()
        let store = await CommonStore.loadStore()
        let isEmpty = await MainActor.run { store.history.isEmpty }
        debugPrintHistory(await MainActor.run { store.history }, label: "After loadEmptyStore")
        #expect(isEmpty, "History should be empty on first run if no data exists")
    }
    
    @Test("Adds and persists an entry")
    func addEntry() async throws {
        clearCommonStoreFile()
        debugPrintFileURL()
        let store = await CommonStore.loadStore()
        let entry = CommonEntry(
            id: UUID(),
            date: .now,
            units: "test unit",
            amount: 1,
            name: "Test Entry",
            goalMet: false
        )
        await store.addEntry(entry: entry)
        // Wait briefly for async save (in real code, inject a dependency for testability)
        try await Task.sleep(nanoseconds: 400_000_000)
        let hasEntry = await MainActor.run { store.history.contains(where: { $0.name == "Test Entry" }) }
        debugPrintHistory(await MainActor.run { store.history }, label: "After addEntry")
        #expect(hasEntry)
    }

    @Test("Removes an entry by ID and persists the change")
    func removeEntryById() async throws {
        clearCommonStoreFile()
        debugPrintFileURL()
        let store = await CommonStore.loadStore()
        let entry = CommonEntry(
            id: UUID(),
            date: .now,
            units: "test unit",
            amount: 1,
            name: "Test Entry",
            goalMet: false
        )
        await store.addEntry(entry: entry)
        try await Task.sleep(nanoseconds: 200_000_000)
        debugPrintHistory(await MainActor.run { store.history }, label: "After adding entry in removeEntryById")
        let existsBefore = await MainActor.run { store.history.contains(where: { $0.id == entry.id }) }
        #expect(existsBefore, "Entry should exist before removal")
        await store.removeEntryAtId(uuid: entry.id)
        try await Task.sleep(nanoseconds: 200_000_000)
        debugPrintHistory(await MainActor.run { store.history }, label: "After removing entry in removeEntryById")
        let existsAfter = await MainActor.run { store.history.contains(where: { $0.id == entry.id }) }
        #expect(!existsAfter, "Entry should not exist after removal")
    }
    
    @Test("Adds multiple entries and persists all")
    func addMultipleEntries() async throws {
        clearCommonStoreFile()
        debugPrintFileURL()
        let store = await CommonStore.loadStore()
        let entry1 = CommonEntry(id: UUID(), date: .now, units: "mg", amount: 10, name: "Entry 1", goalMet: true)
        let entry2 = CommonEntry(id: UUID(), date: .now, units: "mg", amount: 20, name: "Entry 2", goalMet: false)
        await store.addEntry(entry: entry1)
        await store.addEntry(entry: entry2)
        try await Task.sleep(nanoseconds: 200_000_000)
        debugPrintHistory(await MainActor.run { store.history }, label: "After addMultipleEntries")
        let result = await MainActor.run { [entry1, entry2].allSatisfy { entry in store.history.contains(where: { $0.id == entry.id }) } }
        #expect(result, "Both entries should exist in history")
    }

    @Test("Removing a nonexistent entry does not crash or remove others")
    func removeNonexistentEntry() async throws {
        clearCommonStoreFile()
        debugPrintFileURL()
        let store = await CommonStore.loadStore()
        let entry = CommonEntry(id: UUID(), date: .now, units: "mg", amount: 10, name: "Real Entry", goalMet: true)
        await store.addEntry(entry: entry)
        try await Task.sleep(nanoseconds: 200_000_000)
        let fakeID = UUID()
        await store.removeEntryAtId(uuid: fakeID)
        try await Task.sleep(nanoseconds: 200_000_000)
        debugPrintHistory(await MainActor.run { store.history }, label: "After removeNonexistentEntry")
        let stillThere = await MainActor.run { store.history.contains(where: { $0.id == entry.id }) }
        #expect(stillThere, "Existing entry should not be removed when a nonexistent ID is used")
    }

    @Test("Handles duplicate entry names with unique IDs")
    func duplicateEntriesDifferentIDs() async throws {
        clearCommonStoreFile()
        debugPrintFileURL()
        let store = await CommonStore.loadStore()
        let entry1 = CommonEntry(id: UUID(), date: .now, units: "mg", amount: 10, name: "Duplicate", goalMet: true)
        let entry2 = CommonEntry(id: UUID(), date: .now, units: "mg", amount: 20, name: "Duplicate", goalMet: false)
        await store.addEntry(entry: entry1)
        await store.addEntry(entry: entry2)
        try await Task.sleep(nanoseconds: 200_000_000)
        debugPrintHistory(await MainActor.run { store.history }, label: "After adding duplicates")
        let bothThere = await MainActor.run { store.history.filter { $0.name == "Duplicate" }.count == 2 }
        #expect(bothThere, "Both duplicate-named entries with different IDs should exist")
        await store.removeEntryAtId(uuid: entry1.id)
        try await Task.sleep(nanoseconds: 200_000_000)
        debugPrintHistory(await MainActor.run { store.history }, label: "After removing first duplicate")
        let onlySecondLeft = await MainActor.run { store.history.contains(where: { $0.id == entry2.id }) && !store.history.contains(where: { $0.id == entry1.id }) }
        #expect(onlySecondLeft, "First duplicate should be removable independently")
    }

    @Test("Persists history after store reload")
    func persistenceAfterReload() async throws {
        clearCommonStoreFile()
        debugPrintFileURL()
        let entry = CommonEntry(id: UUID(), date: .now, units: "mg", amount: 99, name: "Persisted Entry", goalMet: true)
        do {
            let store = await CommonStore.loadStore()
            await store.addEntry(entry: entry)
            await store.saveAndWait()
            // After saving, read and print the file contents for debugging
            let appGroupID = "group.com.headydiscy.KeepTrack"
            let filename = "entrystore.json"
            if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
                let fileURL = containerURL.appendingPathComponent(filename)
                do {
                    let data = try Data(contentsOf: fileURL)
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                       let jsonDataPretty = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
                       let jsonString = String(data: jsonDataPretty, encoding: .utf8) {
                        print("[DEBUG] Saved file contents:\n\(jsonString)")
                    } else if let string = String(data: data, encoding: .utf8) {
                        print("[DEBUG] Saved file raw contents:\n\(string)")
                    } else {
                        print("[DEBUG] Saved file contents could not be decoded as UTF-8 string")
                    }
                } catch {
                    print("[DEBUG] Failed to read saved file: \(error)")
                }
            } else {
                print("[DEBUG] Failed to get App Group URL for reading saved file!")
            }
            debugPrintHistory(await MainActor.run { store.history }, label: "Before reload in persistenceAfterReload")
        }
        let storeReloaded = await CommonStore.loadStore()
        debugPrintHistory(await MainActor.run { storeReloaded.history }, label: "After reload in persistenceAfterReload")
        let found = await MainActor.run { storeReloaded.history.contains(where: { $0.id == entry.id }) }
        #expect(found, "Entry should still exist after store reload")
    }
}

