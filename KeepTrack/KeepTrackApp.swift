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
                }
                
                // Show license on top of everything if not accepted
                if !licenseManager.isCheckingLicense && !licenseManager.hasAcceptedCurrentVersion {
                    LicenseView(licenseManager: licenseManager) {
                        licenseManager.acceptLicense()
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    let onNotificationTap: (String, Date) -> Void
    init(onNotificationTap: @escaping (String, Date) -> Void) {
        self.onNotificationTap = onNotificationTap
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        // expects identifier in form: reminder-<goal.id>-<timestamp>
        if let dashRange = identifier.range(of: "-", options: .backwards),
           let timestamp = Double(identifier[dashRange.upperBound...]) {
            let name = response.notification.request.content.body
                .replacingOccurrences(of: "Did you take your ", with: "")
                .components(separatedBy: " ")[0]
            self.onNotificationTap(name, Date(timeIntervalSince1970: timestamp))
        }
        completionHandler()
    }
}
