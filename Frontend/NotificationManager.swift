//
//  NotificationManager.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 25/12/2024.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    // Singleton instance
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        requestAuthorization()
    }
    
    // Request notification authorization with detailed logging
    func requestAuthorization() {
        // Set the delegate before requesting authorization
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission GRANTED")
                    self?.scheduleReadingNotifications()
                } else {
                    print("❌ Notification permission DENIED")
                }
                
                if let error = error {
                    print("🚨 Notification authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // UNUserNotificationCenterDelegate method to handle notifications when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    // Schedule recurring reading notifications every 8 hours
    private func scheduleReadingNotifications() {
        // Remove any existing notifications to prevent duplicates
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Array of motivational reading messages
        let motivationalMessages = [
            "Time to dive into a good book! 📖",
            "Reading is a journey of the mind. Where will you go today? 🌟",
            "A few pages can transform your day. Let's read! 📚",
            "Your next adventure awaits between the pages. 🚀",
            "Reading: The best escape from reality. 🌈",
            "Knowledge grows with every page you turn. 🧠",
            "Make time for reading today! ⏰",
            "Books are windows to infinite worlds. Open one! 🌍"
        ]
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Reading Time!"
        content.sound = .default
        
        // Randomly select a motivational message
        content.body = motivationalMessages.randomElement() ?? "Time to read!"
        
        // Create triggers for every 8 hours
        let triggers = [
            UNTimeIntervalNotificationTrigger(timeInterval: 8 * 60 * 60, repeats: true),
            UNTimeIntervalNotificationTrigger(timeInterval: 16 * 60 * 60, repeats: true),
            UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: true)
        ]
        
        // Create and add notification requests
        for (index, trigger) in triggers.enumerated() {
            let request = UNNotificationRequest(
                identifier: "readingNotification\(index)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("✅ Notification \(index) scheduled successfully")
                }
            }
        }
    }
    
    // Comprehensive method to check notification status
    func checkNotificationStatus(completion: @escaping (Bool, String) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    completion(true, "Notifications are authorized")
                case .denied:
                    completion(false, "Notifications are denied. Please enable in Settings.")
                case .notDetermined:
                    completion(false, "Notification permission not yet determined")
                case .provisional:
                    completion(true, "Provisional notifications enabled")
                @unknown default:
                    completion(false, "Unknown notification status")
                }
            }
        }
    }
    
    // Trigger methods with comprehensive error handling
    func triggerTestNotification() {
        checkNotificationStatus { isEnabled, message in
            guard isEnabled else {
                print("❌ Cannot send notification: \(message)")
                return
            }
            
            self.sendNotification(
                title: "Test Notification",
                body: "This is a manual test notification for development"
            )
        }
    }
    
    func triggerRandomMotivationalNotification() {
        checkNotificationStatus { isEnabled, message in
            guard isEnabled else {
                print("❌ Cannot send notification: \(message)")
                return
            }
            
            let motivationalMessages = [
                "Time to dive into a good book! 📖",
                "Reading is a journey of the mind. Where will you go today? 🌟",
                "A few pages can transform your day. Let's read! 📚"
            ]
            
            self.sendNotification(
                title: "Reading Time!",
                body: motivationalMessages.randomElement() ?? "Time to read!"
            )
        }
    }
    
    func triggerSpecificNotification(message: String) {
        checkNotificationStatus { isEnabled, statusMessage in
            guard isEnabled else {
                print("❌ Cannot send notification: \(statusMessage)")
                return
            }
            
            self.sendNotification(
                title: "Reading Time!",
                body: message
            )
        }
    }
    
    // Generic method to send notifications
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification sent successfully")
            }
        }
    }
}

