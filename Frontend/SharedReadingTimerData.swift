//
//  SharedReadingTimerData.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 21/12/2024.
//

import Foundation
import SwiftUI
import WidgetKit

class ReadingTimerSharedData: ObservableObject {
    // Singleton instance
    static let shared = ReadingTimerSharedData()
    
    // Use the shared app group UserDefaults
    private let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
    
    // UserDefaults key for storing timer data
    private let timerKey = "currentReadingTimer"
    
    // Published property to track the current timer
    @Published var currentTimer: ReadingTimerEntry? {
        didSet {
            saveTimer()
            // Reload widget timeline when timer changes
            WidgetCenter.shared.reloadTimelines(ofKind: "ReadingTimerWidget")
        }
    }
    
    // Private initializer to ensure singleton
    private init() {
        loadTimer()
    }
    
    // Start a new timer
    func startTimer(bookTitle: String) {
        let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
        defaults.set(Date(), forKey: "timerStartTime")
        defaults.set(bookTitle, forKey: "mostReadBookTitle")
        
        currentTimer = ReadingTimerEntry(
            bookTitle: bookTitle,
            elapsedTime: 0,
            startTime: Date()
        )
    }

    func stopTimer() {
        let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
        defaults.removeObject(forKey: "timerStartTime")
        
        currentTimer = nil
    }

    
    // Update the current timer's elapsed time
    func updateTimer() {
        guard var timer = currentTimer else { return }
        timer.elapsedTime = Date().timeIntervalSince(timer.startTime)
        currentTimer = timer
    }
    
    // Save timer to UserDefaults
    private func saveTimer() {
        guard let timer = currentTimer else {
            defaults.removeObject(forKey: timerKey)
            return
        }
        
        do {
            let encodedData = try JSONEncoder().encode(timer)
            defaults.set(encodedData, forKey: timerKey)
        } catch {
            print("Error saving timer: \(error)")
        }
    }
    
    // Load timer from UserDefaults
    private func loadTimer() {
        guard let data = defaults.data(forKey: timerKey) else {
            return
        }
        
        do {
            currentTimer = try JSONDecoder().decode(ReadingTimerEntry.self, from: data)
        } catch {
            print("Error loading timer: \(error)")
        }
    }
}

// Struct to represent the reading timer entry
struct ReadingTimerEntry: Codable, Equatable {
    let bookTitle: String
    var elapsedTime: TimeInterval
    let startTime: Date
}

