//
//  ReadingTimerWidgetControl.swift
//  ReadingTimerWidget
//
//  Created by arslaan ahmed on 21/12/2024.
//

import AppIntents
import SwiftUI
import WidgetKit

struct ReadingTimerWidgetControl: ControlWidget {
    static let kind: String = "ReadingTimerWidget"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: ReadingTimerControlProvider()
        ) { controlValue in
            ControlWidgetToggle(
                "Reading Timer",
                isOn: controlValue.isRunning,
                action: ToggleTimerIntent(value: !controlValue.isRunning)
            ) { isRunning in
                Label(isRunning ? "Reading" : "Start", systemImage: "book")
            }
        }
        .displayName("Reading Timer")
        .description("Control your reading timer")
    }
}

struct ReadingTimerControlProvider: AppIntentControlValueProvider {
    func previewValue(configuration: ReadingTimerConfiguration) -> ReadingTimerControlValue {
        ReadingTimerControlValue(isRunning: false, name: configuration.timerName)
    }
    
    func currentValue(configuration: ReadingTimerConfiguration) async throws -> ReadingTimerControlValue {
        let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
        let isRunning = defaults.bool(forKey: "isTimerRunning")
        
        return ReadingTimerControlValue(
            isRunning: isRunning,
            name: configuration.timerName
        )
    }
}

struct ReadingTimerControlValue {
    var isRunning: Bool
    var name: String
}

struct ReadingTimerConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Timer Configuration"
    
    @Parameter(title: "Timer Name", default: "Reading Timer")
    var timerName: String
}

struct ToggleTimerIntent: SetValueIntent {
    static var title: LocalizedStringResource = "Toggle Timer"
    
    @Parameter(title: "Timer Running")
    var value: Bool
    
    init() {}
    
    init(value: Bool) {
        self.value = value
    }
    
    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
        
        if value {
            // Start timer
            if let bookTitle = defaults.string(forKey: "mostReadBookTitle") {
                defaults.set(Date(), forKey: "timerStartTime")
                defaults.set(true, forKey: "isTimerRunning")
            }
        } else {
            // Stop timer
            defaults.removeObject(forKey: "timerStartTime")
            defaults.set(false, forKey: "isTimerRunning")
        }
        
        // Reload widget and control widget timelines
        WidgetCenter.shared.reloadTimelines(ofKind: "ReadingTimerWidget")
        
        return .result()
    }
}






