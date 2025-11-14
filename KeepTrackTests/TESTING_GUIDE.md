# CommonStore Testing Strategy

## Overview

This document explains the testing strategy for `CommonStore` and how to write reliable, isolated tests.

## Architecture Changes

### Dependency Injection

`CommonStore` now supports dependency injection through the `CommonStoreStorage` protocol:

```swift
protocol CommonStoreStorage {
    func load() async throws -> [CommonEntry]
    func save(_ entries: [CommonEntry]) async throws
}
```

### Storage Implementations

1. **`AppGroupStorage`** - Production implementation
   - Uses App Group container for file persistence
   - Shared between app and app extensions
   - Default when no storage is specified

2. **`InMemoryStorage`** - Test implementation
   - Stores data in memory only
   - No file system access
   - Perfect for unit testing
   - Optional delay simulation for testing timing issues

## Test Files

### CommonStoreTestsImproved.swift ✅ RECOMMENDED

**Purpose:** Comprehensive unit tests with complete isolation

**Advantages:**
- ✅ No race conditions
- ✅ Fast execution
- ✅ No file cleanup needed
- ✅ Can run in parallel
- ✅ Deterministic results
- ✅ Complete test coverage of all CommonStore functionality

**What it tests:**
- Empty store loading
- Adding single and multiple entries
- Removing entries by ID
- Handling nonexistent entry removal
- Duplicate entry names with unique IDs
- Persistence across store reloads
- History sorting by date (descending)
- Today's intake filtering

**Usage:**
```swift
let storage = InMemoryStorage()
let store = await CommonStore.loadStore(storage: storage)
```

**When to use:** For all unit tests and feature testing. This is the single source of truth for CommonStore testing.

## Writing New Tests

### For Unit Tests (Recommended)

```swift
@Test("Your test description")
func yourTest() async throws {
    // 1. Create isolated storage
    let storage = InMemoryStorage()
    
    // 2. Create store with test storage
    let store = await CommonStore.loadStore(storage: storage)
    
    // 3. Test your functionality
    let entry = CommonEntry(...)
    await store.addEntry(entry: entry)
    
    // 4. Verify results
    let hasEntry = await MainActor.run { 
        store.history.contains(where: { $0.id == entry.id })
    }
    #expect(hasEntry)
    
    // 5. Optionally verify storage directly
    let saved = try await storage.load()
    #expect(saved.count == 1)
}
```

## Best Practices

### DO ✅

1. **Use `InMemoryStorage` for all tests**
2. **Use dependency injection** via `CommonStore.loadStore(storage:)`
3. **Test one thing per test**
4. **Use descriptive test names**
5. **Add helpful failure messages to `#expect()`**
6. **Test edge cases** (empty data, duplicates, etc.)

### DON'T ❌

1. **Don't rely on shared state** between tests
2. **Don't use arbitrary sleep times** without good reason
3. **Don't test file system details** in unit tests
4. **Don't run integration tests in parallel**
5. **Don't forget to clean up** in integration tests

## Running Tests

### Run All Tests
```
⌘U or Product > Test
```

### Run Specific Test Suite
- Click the diamond next to `@Suite` in the editor

### Run Single Test
- Click the diamond next to `@Test` in the editor

### Run from Test Navigator
- Press ⌘6 to open Test Navigator
- Click any test or suite to run it

## Debugging Test Failures

### For Unit Tests (InMemoryStorage)

1. **Check the test logic** - The test should be deterministic
2. **Verify MainActor usage** - Make sure you're accessing `history` on MainActor
3. **Check async/await** - Ensure all async operations complete before assertions

### For Integration Tests (File System)

1. **Check debug output** - Look for `[DEBUG]` messages in console
2. **Verify file cleanup** - Make sure `clearCommonStoreFile()` is called
3. **Increase sleep times** - If tests are flaky, they may need more time
4. **Run tests individually** - See if the test passes when run alone
5. **Check App Group entitlements** - Verify your test target has the right entitlements

## Migration Guide

### Migrating Existing Production Code

Production code continues to work without changes:

```swift
// This still works - uses AppGroupStorage by default
let store = await CommonStore.loadStore()
```

### Migrating Existing Tests

1. **Identify test type:**
   - Unit test? → Use `InMemoryStorage`
   - Integration test? → Keep using default storage

2. **For unit tests, add storage parameter:**
   ```swift
   // Before
   let store = await CommonStore.loadStore()
   
   // After
   let storage = InMemoryStorage()
   let store = await CommonStore.loadStore(storage: storage)
   ```

3. **Remove timing workarounds:**
   ```swift
   // Before
   await store.addEntry(entry: entry)
   try await Task.sleep(nanoseconds: 500_000_000)
   
   // After (with InMemoryStorage, no sleep needed)
   await store.addEntry(entry: entry)
   ```

4. **Remove file cleanup:**
   ```swift
   // Before
   clearCommonStoreFile()
   try await Task.sleep(nanoseconds: 100_000_000)
   
   // After (with InMemoryStorage, not needed)
   // Just create new storage instance
   ```

## Example: Complete Test

```swift
@Test("Adding multiple entries keeps them sorted by date")
func sortingMultipleEntries() async throws {
    // Arrange
    let storage = InMemoryStorage()
    let store = await CommonStore.loadStore(storage: storage)
    
    let now = Date.now
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
    
    let entry1 = CommonEntry(id: UUID(), date: yesterday, units: "mg", 
                            amount: 1, name: "Yesterday", goalMet: false)
    let entry2 = CommonEntry(id: UUID(), date: tomorrow, units: "mg", 
                            amount: 2, name: "Tomorrow", goalMet: false)
    let entry3 = CommonEntry(id: UUID(), date: now, units: "mg", 
                            amount: 3, name: "Today", goalMet: false)
    
    // Act
    await store.addEntry(entry: entry1)
    await store.addEntry(entry: entry2)
    await store.addEntry(entry: entry3)
    
    // Assert
    let history = await MainActor.run { store.history }
    #expect(history.count == 3, "Should have 3 entries")
    #expect(history[0].name == "Tomorrow", "Newest entry should be first")
    #expect(history[1].name == "Today", "Middle entry should be second")
    #expect(history[2].name == "Yesterday", "Oldest entry should be last")
}
```

## Summary

- ✅ Use **`CommonStoreTestsImproved.swift`** as the template for all tests
- ✅ Use **`InMemoryStorage`** for fast, reliable unit tests
- ✅ Follow the **dependency injection pattern** for testability
- ✅ Write **descriptive test names** and **helpful assertions**
- ✅ All CommonStore functionality is covered by the improved test suite

## Questions?

If you encounter issues:
1. Check if you're using the right storage type for your test
2. Verify MainActor usage for accessing `history`
3. Look at `CommonStoreTestsImproved.swift` for examples
4. Use `InMemoryStorage` for all new tests
