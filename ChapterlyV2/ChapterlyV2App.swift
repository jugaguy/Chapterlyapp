//
//  ChapterlyV2App.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 15/11/2024.
//

import SwiftUI
import UserNotifications

@main
struct ChapterlyV2App: App {
    // Set this to true to always show IntroductionView (for testing)
    private let alwaysShowIntro = false

    // Keep the AppStorage for future production use
    @AppStorage("hasCompletedIntro") private var hasCompletedIntro = false

    // Initialize NotificationManager when the app starts
    init() {
        // This will trigger the authorization request
        _ = NotificationManager.shared
    }

    var body: some Scene {
        WindowGroup {
            // If alwaysShowIntro is true, always show IntroductionView
            // Otherwise, use the standard logic
            if alwaysShowIntro {
                IntroductionView()
            } else {
                if hasCompletedIntro {
                    MainScreen()
                } else {
                    IntroductionView()
                }
            }
        }
    }
}



