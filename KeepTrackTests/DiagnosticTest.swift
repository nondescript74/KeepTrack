//
//  DiagnosticTest.swift
//  KeepTrackTests
//

import Foundation
import Testing
@testable import KeepTrack

@Suite("Diagnostic Tests")
struct DiagnosticTest {
    
    @Test("Can import KeepTrack module")
    func canImportModule() {
        print("✅ Module imported successfully")
        #expect(true)
    }
    
    @Test("Can create CommonEntry")
    func canCreateCommonEntry() {
        let entry = CommonEntry(
            id: UUID(),
            date: .now,
            units: "mg",
            amount: 100,
            name: "Test",
            goalMet: false
        )
        print("✅ Created CommonEntry: \(entry.name)")
        #expect(entry.name == "Test")
        #expect(entry.amount == 100)
        #expect(entry.units == "mg")
    }
    
    @Test("Can create InMemoryStorage")
    func canCreateStorage() async throws {
        let storage = InMemoryStorage()
        print("✅ Created InMemoryStorage")
        
        // Verify it can load (should return empty array)
        let entries = try await storage.load()
        #expect(entries.isEmpty, "New storage should be empty")
        print("✅ Storage loads successfully")
    }
    
    @Test("Can create CommonStore with storage")
    @MainActor
    func canCreateCommonStore() async throws {
        print("🔍 Attempting to create CommonStore...")
        let storage = InMemoryStorage()
        print("✅ Storage created")
        
        let store = await CommonStore.loadStore(storage: storage)
        print("✅ CommonStore created")
        
        #expect(store.history.isEmpty, "New store should have empty history")
        print("✅ CommonStore test completed successfully")
    }
    
    @Test("Can add entry to CommonStore")
    @MainActor
    func canAddEntryToStore() async throws {
        print("🔍 Testing add entry...")
        let storage = InMemoryStorage()
        let store = await CommonStore.loadStore(storage: storage)
        
        let entry = CommonEntry(
            id: UUID(),
            date: .now,
            units: "mg",
            amount: 50,
            name: "Diagnostic Entry",
            goalMet: false
        )
        
        await store.addEntry(entry: entry)
        print("✅ Entry added")
        
        #expect(store.history.count == 1, "Store should have 1 entry")
        #expect(store.history.first?.name == "Diagnostic Entry", "Entry name should match")
        print("✅ Add entry test completed successfully")
    }
}
