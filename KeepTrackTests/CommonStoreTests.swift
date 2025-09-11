//
//  CommonStoreTests.swift
//  KeepTrackTests
//
//  Created by Zahirudeen Premji on 9/11/25.
//

import Foundation
import Testing
@testable import KeepTrack

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
        let store = await CommonStore.loadStore()
        let isEmpty = await MainActor.run { store.history.isEmpty }
        #expect(isEmpty, "History should be empty on first run if no data exists")
    }
    
    @Test("Adds and persists an entry")
    func addEntry() async throws {
        clearCommonStoreFile()
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
        try await Task.sleep(nanoseconds: 200_000_000)
        let hasEntry = await MainActor.run { store.history.contains(where: { $0.name == "Test Entry" }) }
        #expect(hasEntry)
    }
}
