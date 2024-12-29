//
//  SharedImports.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 22/12/2024.
//

import Foundation
import UserNotifications


// Simplified version of your shared data class
class ReadingTimerSharedData {
    static let shared = ReadingTimerSharedData()
    
    private let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
    
    struct ReadingTimerEntry: Codable {
        let bookTitle: String
        var elapsedTime: TimeInterval
        let startTime: Date
    }
    
    var currentTimer: ReadingTimerEntry? {
        get {
            guard let data = defaults.data(forKey: "currentReadingTimer") else {
                return nil
            }
            return try? JSONDecoder().decode(ReadingTimerEntry.self, from: data)
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: "currentReadingTimer")
            }
        }
    }
    
    func startTimer(bookTitle: String) {
        currentTimer = ReadingTimerEntry(
            bookTitle: bookTitle,
            elapsedTime: 0,
            startTime: Date()
        )
    }
    
    func stopTimer() {
        currentTimer = nil
    }
}

// Simplified Book model for widget
struct WidgetBook {
    let title: String
}

// Simplified Book ViewModel for widget
class WidgetBookViewModel {
    func getMostReadBook() -> WidgetBook? {
        // Implement a simple way to get the most read book
        // This might involve reading from UserDefaults or a simplified data store
        guard let bookTitle = UserDefaults(suiteName: "group.com.juga.chapterlyV2")?.string(forKey: "mostReadBookTitle") else {
            return nil
        }
        return WidgetBook(title: bookTitle)
    }
}


