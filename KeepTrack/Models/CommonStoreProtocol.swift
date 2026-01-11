//
//  CommonStoreProtocol.swift
//  KeepTrack
//
//  Created on 11/13/25.
//

import Foundation

/// Protocol for storage backends that CommonStore can use
public protocol CommonStoreStorage {
    func load() async throws -> [CommonEntry]
    func save(_ entries: [CommonEntry]) async throws
}

/// Production storage implementation using App Group container
public final class AppGroupStorage: CommonStoreStorage, @unchecked Sendable {
    private let fileURL: URL
    private let filename: String
    
    public init(appGroupID: String = "group.com.headydiscy.KeepTrack", filename: String = "entrystore.json") throws {
        self.filename = filename
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            throw CommonStoreError.containerNotFound
        }
        self.fileURL = containerURL.appendingPathComponent(filename)
    }
    
    public func load() async throws -> [CommonEntry] {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                if FileManager.default.fileExists(atPath: self.fileURL.path) {
                    do {
                        let data = try Data(contentsOf: self.fileURL)
                        if data.isEmpty {
                            continuation.resume(returning: [])
                        } else {
                            let entries = try JSONDecoder().decode([CommonEntry].self, from: data)
                            continuation.resume(returning: entries)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    // Create empty file
                    FileManager.default.createFile(atPath: self.fileURL.path, contents: nil)
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    public func save(_ entries: [CommonEntry]) async throws {
        try await withCheckedThrowingContinuation { [entries] (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .background).async {
                do {
                    let data = try JSONEncoder().encode(entries)
                    try data.write(to: self.fileURL, options: [.atomic])
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

/// In-memory storage implementation for testing
public final class InMemoryStorage: CommonStoreStorage {
    private var entries: [CommonEntry] = []
    private let delay: UInt64
    
    /// - Parameter delay: Optional delay in nanoseconds to simulate async behavior
    public init(delay: UInt64 = 0) {
        self.delay = delay
    }
    
    public func load() async throws -> [CommonEntry] {
        if delay > 0 {
            try await Task.sleep(nanoseconds: delay)
        }
        return entries
    }
    
    public func save(_ entries: [CommonEntry]) async throws {
        if delay > 0 {
            try await Task.sleep(nanoseconds: delay)
        }
        self.entries = entries
    }
    
    /// Test helper to directly access stored entries
    public func getStoredEntries() -> [CommonEntry] {
        return entries
    }
}

public enum CommonStoreError: Error {
    case containerNotFound
    case loadFailed(Error)
    case saveFailed(Error)
}
