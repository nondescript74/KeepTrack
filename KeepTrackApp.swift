//
//  KeepTrackApp.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 3/18/25.
//

import SwiftUI
import UserNotifications

class KeepTrackAppState {
    static var notificationDelegate: NotificationDelegate?
}

class PendingNotificationHolder: ObservableObject {
    @Published var pendingNotification: PendingNotification? = nil
}

@main
struct KeepTrackApp: App {
    @StateObject private var currentIntakeTypes = CurrentIntakeTypes()
    @StateObject private var notificationHolder: PendingNotificationHolder
    @State private var showLaunchScreen = true
    @State private var licenseManager = LicenseManager()
    
    // SwiftData
    private let swiftDataManager = SwiftDataManager.shared

    init() {
        let holder = PendingNotificationHolder()
        let delegate = NotificationDelegate { name, date in
            DispatchQueue.main.async {
                holder.pendingNotification = PendingNotification(name: name, goalDate: date)
            }
        }
        KeepTrackAppState.notificationDelegate = delegate
        UNUserNotificationCenter.current().delegate = delegate
        _notificationHolder = StateObject(wrappedValue: holder)
        
        // Setup notification categories for action buttons
        IntakeReminderManager.setupNotificationCategories()
        
        // UserDefaults.standard.removeObject(forKey: "AcceptedLicenseVersion")
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchScreen()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                withAnimation { showLaunchScreen = false }
                            }
                        }
                } else {
                    NewDashboard(pendingNotification: $notificationHolder.pendingNotification)
                        .environmentObject(currentIntakeTypes)
                        .fullScreenCover(isPresented: .constant(!licenseManager.isCheckingLicense && !licenseManager.hasAcceptedCurrentVersion)) {
                            LicenseView(licenseManager: licenseManager) {
                                licenseManager.acceptLicense()
                            }
                        }
                        .task {
                            // Perform one-time migration on app launch
                            await performInitialMigration()
                        }
                }
            }
        }
        .modelContainer(swiftDataManager.container)
    }
    
    // MARK: - Migration
    
    @MainActor
    private func performInitialMigration() async {
        let versionChecker = SchemaVersionChecker.shared
        let migrationManager = DataMigrationManager(modelContext: swiftDataManager.mainContext)
        
        // Check if this is a first-time migration from JSON to SwiftData
        guard !migrationManager.isMigrationCompleted else {
            // JSON migration already done, but check schema version
            if versionChecker.needsMigration() {
                print("⚠️ Schema migration from V1 to V2 will occur automatically")
                // The migration happens automatically via KeepTrackSchemaMigrationPlan
                // We just need to record it after successful launch
                versionChecker.recordMigrationToV2()
            }
            return
        }
        
        do {
            // First-time migration from JSON to SwiftData V2
            try await migrationManager.migrateAllData()
            versionChecker.recordMigrationToV2()
            print("✅ Initial data migration completed")
        } catch {
            print("❌ Migration failed: \(error.localizedDescription)")
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    let onNotificationTap: (String, Date) -> Void
    
    init(onNotificationTap: @escaping (String, Date) -> Void) {
        self.onNotificationTap = onNotificationTap
    }
    
    // Called when notification will be presented while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Task {
            // Check if we should suppress this reminder
            let userInfo = notification.request.content.userInfo
            guard let goalIDString = userInfo["goalID"] as? String,
                  let goalID = UUID(uuidString: goalIDString),
                  let goalName = userInfo["goalName"] as? String else {
                completionHandler([.banner, .sound, .badge])
                return
            }
            
            // Load store and check if intake was already logged
            let store = await CommonStore.loadStore()
            
            // Get the scheduled time from the trigger
            if let trigger = notification.request.trigger as? UNCalendarNotificationTrigger,
               let nextTriggerDate = trigger.nextTriggerDate() {
                
                // Cancel any superseded reminders
                await IntakeReminderManager.cancelSupersededReminders(for: goalID, currentScheduledTime: nextTriggerDate)
                
                // Check if we should suppress
                if await IntakeReminderManager.shouldSuppressReminder(
                    for: CommonGoal(id: goalID, name: goalName, description: "", dates: [], 
                                  isActive: true, isCompleted: false, dosage: 0, units: "", frequency: ""),
                    scheduledTime: nextTriggerDate,
                    store: store
                ) {
                    // Don't show the notification
                    completionHandler([])
                    return
                }
            }
            
            // Show the notification normally
            completionHandler([.banner, .sound, .badge])
        }
    }
    
    // Called when user interacts with notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              didReceive response: UNNotificationResponse, 
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let notificationIdentifier = response.notification.request.identifier
        
        Task {
            switch response.actionIdentifier {
            case "CONFIRM_ACTION":
                // User confirmed they took the intake - log it now
                await handleConfirmAction(userInfo: userInfo)
                
            case "CANCEL_ACTION":
                // User cancelled - cancel this specific reminder permanently
                await handleCancelAction(userInfo: userInfo, notificationIdentifier: notificationIdentifier)
                
            case UNNotificationDefaultActionIdentifier:
                // User tapped the notification body - show the dialog
                if let goalName = userInfo["goalName"] as? String,
                   let nextTriggerDate = (response.notification.request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() {
                    self.onNotificationTap(goalName, nextTriggerDate)
                }
                
            default:
                break
            }
            
            completionHandler()
        }
    }
    
    private func handleConfirmAction(userInfo: [AnyHashable: Any]) async {
        guard let goalName = userInfo["goalName"] as? String,
              let units = userInfo["units"] as? String,
              let dosage = userInfo["dosage"] as? Double else {
            print("Missing required user info for confirm action")
            return
        }
        
        // Load store and add entry at current time
        let store = await CommonStore.loadStore()
        
        let entry = CommonEntry(
            id: UUID(),
            date: Date(), // Log at the time user pressed confirm
            units: units,
            amount: dosage,
            name: goalName,
            goalMet: true
        )
        
        await store.addEntry(entry: entry)
        print("Logged intake for \(goalName) at \(Date())")
    }
    
    private func handleCancelAction(userInfo: [AnyHashable: Any], notificationIdentifier: String) async {
        guard let goalIDString = userInfo["goalID"] as? String,
              let goalID = UUID(uuidString: goalIDString) else {
            print("Missing goal ID for cancel action")
            return
        }
        
        // Cancel this specific reminder
        IntakeReminderManager.cancelReminder(withIdentifier: notificationIdentifier)
        print("Cancelled reminder \(notificationIdentifier) for goal \(goalID)")
    }
}
