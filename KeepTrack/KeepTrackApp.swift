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
            NewDashboard(pendingNotification: $notificationHolder.pendingNotification)
                .environmentObject(currentIntakeTypes)
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
