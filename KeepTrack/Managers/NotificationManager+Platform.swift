//
//  NotificationManager+Platform.swift
//  KeepTrack
//
//  Created on 1/12/26.
//

import Foundation
import UserNotifications

/// Cross-platform notification manager
/// Handles differences between iOS and macOS notification systems
@MainActor
class PlatformNotificationManager {
    static let shared = PlatformNotificationManager()
    
    private init() {}
    
    // MARK: - Authorization
    
    /// Request notification permissions
    /// Works on both iOS and macOS with platform-appropriate options
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        
        #if os(macOS)
        // macOS doesn't support badges
        let options: UNAuthorizationOptions = [.alert, .sound]
        #else
        // iOS supports badges
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        #endif
        
        return try await center.requestAuthorization(options: options)
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Scheduling
    
    /// Schedule a notification
    func scheduleNotification(
        identifier: String,
        title: String,
        body: String,
        date: Date,
        repeats: Bool = false
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Create date components from the date
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: repeats
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        let center = UNUserNotificationCenter.current()
        try await center.add(request)
    }
    
    /// Schedule a notification with time interval
    func scheduleNotification(
        identifier: String,
        title: String,
        body: String,
        timeInterval: TimeInterval,
        repeats: Bool = false
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: repeats
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        let center = UNUserNotificationCenter.current()
        try await center.add(request)
    }
    
    // MARK: - Management
    
    /// Get all pending notification requests
    func getPendingNotifications() async -> [UNNotificationRequest] {
        let center = UNUserNotificationCenter.current()
        return await center.pendingNotificationRequests()
    }
    
    /// Remove specific notification
    func removeNotification(withIdentifier identifier: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Remove all pending notifications
    func removeAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Badge (iOS only)
    
    #if os(iOS)
    /// Set app badge number (iOS only)
    func setBadgeCount(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }
    
    /// Clear app badge (iOS only)
    func clearBadge() {
        setBadgeCount(0)
    }
    #endif
}

// MARK: - Notification Delegate

/// Platform-agnostic notification delegate
/// Handles notification responses on both iOS and macOS
@MainActor
class PlatformNotificationDelegate: NSObject, @preconcurrency UNUserNotificationCenterDelegate {
    
    // Called when notification is received while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        #if os(macOS)
        // macOS: Show alert and play sound
        completionHandler([.sound, .banner])
        #else
        // iOS: Show banner, play sound, and update badge
        completionHandler([.banner, .sound, .badge])
        #endif
    }
    
    // Called when user taps on notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        _ = response.notification.request.content.userInfo
        
        // Handle the notification tap
        // You can parse userInfo to determine what action to take
        
        completionHandler()
    }
}

// MARK: - Usage Example

/*
 
 // In your App file:
 
 @main
 struct KeepTrackApp: App {
     @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate  // iOS
     // OR
     @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate  // macOS
     
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }
 
 // In your AppDelegate:
 
 class AppDelegate: NSObject, UIApplicationDelegate {  // iOS
 // OR
 class AppDelegate: NSObject, NSApplicationDelegate {  // macOS
     
     func application(
         _ application: UIApplication,
         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
         // Set notification delegate
         UNUserNotificationCenter.current().delegate = PlatformNotificationDelegate()
         return true
     }
 }
 
 // Requesting permission:
 
 Task {
     do {
         let granted = try await PlatformNotificationManager.shared.requestAuthorization()
         if granted {
             print("Notifications authorized")
         }
     } catch {
         print("Error requesting notification authorization: \(error)")
     }
 }
 
 // Scheduling a notification:
 
 Task {
     do {
         try await PlatformNotificationManager.shared.scheduleNotification(
             identifier: "reminder-123",
             title: "Medication Reminder",
             body: "Time to take your morning medication",
             date: Date().addingTimeInterval(3600), // 1 hour from now
             repeats: false
         )
     } catch {
         print("Error scheduling notification: \(error)")
     }
 }
 
 */
