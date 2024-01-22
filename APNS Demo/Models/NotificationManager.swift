//
//  NotificationManager.swift
//  APNS Demo
//
//  Created by Rayan Khan on 1/19/24.
//

import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject {
    @Published var notificationStatus: String = "Unknown"
    @Published var pushNotificationToken: String = "No Token"
    
    init() {
        checkNotificationAuthorization()
    }
    
    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.notificationStatus = "Not Determined"
                case .denied:
                    self.notificationStatus = "Denied"
                case .authorized, .provisional, .ephemeral:
                    self.notificationStatus = "Authorized"
                @unknown default:
                    self.notificationStatus = "Unknown"
                }
            }
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self?.notificationStatus = "Authorized"
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    self?.notificationStatus = "Denied"
                }
            }
        }
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        DispatchQueue.main.async {
            self.pushNotificationToken = token
            print(self.pushNotificationToken)
        }
    }
}
