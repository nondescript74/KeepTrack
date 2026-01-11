//
//  NotificationCenterProtocol.swift
//  KeepTrack
//
//  Created on 1/11/26.
//

import Foundation
import UserNotifications

/// Protocol abstracting UNUserNotificationCenter for testability
protocol NotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func getPendingNotificationRequests() async -> [UNNotificationRequest]
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>)
}

/// Production wrapper for UNUserNotificationCenter
class ProductionNotificationCenter: NotificationCenterProtocol {
    private let center: UNUserNotificationCenter
    
    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            center.requestAuthorization(options: options) { granted, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    func add(_ request: UNNotificationRequest) async throws {
        try await center.add(request)
    }
    
    func getPendingNotificationRequests() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removeAllPendingNotificationRequests() {
        center.removeAllPendingNotificationRequests()
    }
    
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>) {
        center.setNotificationCategories(categories)
    }
}

/// Mock notification center for testing
class MockNotificationCenter: NotificationCenterProtocol {
    var authorizationGranted = true
    var pendingRequests: [UNNotificationRequest] = []
    var categories: Set<UNNotificationCategory> = []
    
    // Track calls for testing
    var requestAuthorizationCalled = false
    var addRequestCalls: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    var removeAllCalled = false
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestAuthorizationCalled = true
        return authorizationGranted
    }
    
    func add(_ request: UNNotificationRequest) async throws {
        addRequestCalls.append(request)
        pendingRequests.append(request)
    }
    
    func getPendingNotificationRequests() async -> [UNNotificationRequest] {
        return pendingRequests
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
        pendingRequests.removeAll { identifiers.contains($0.identifier) }
    }
    
    func removeAllPendingNotificationRequests() {
        removeAllCalled = true
        pendingRequests.removeAll()
    }
    
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>) {
        self.categories = categories
    }
    
    // Helper to reset mock state
    func reset() {
        authorizationGranted = true
        pendingRequests.removeAll()
        categories.removeAll()
        requestAuthorizationCalled = false
        addRequestCalls.removeAll()
        removedIdentifiers.removeAll()
        removeAllCalled = false
    }
}
