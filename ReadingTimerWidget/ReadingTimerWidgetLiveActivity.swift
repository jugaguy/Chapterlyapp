//
//  ReadingTimerWidgetLiveActivity.swift
//  ReadingTimerWidget
//
//  Created by arslaan ahmed on 21/12/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ReadingTimerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ReadingTimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ReadingTimerWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ReadingTimerWidgetAttributes {
    fileprivate static var preview: ReadingTimerWidgetAttributes {
        ReadingTimerWidgetAttributes(name: "World")
    }
}

extension ReadingTimerWidgetAttributes.ContentState {
    fileprivate static var smiley: ReadingTimerWidgetAttributes.ContentState {
        ReadingTimerWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ReadingTimerWidgetAttributes.ContentState {
         ReadingTimerWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ReadingTimerWidgetAttributes.preview) {
   ReadingTimerWidgetLiveActivity()
} contentStates: {
    ReadingTimerWidgetAttributes.ContentState.smiley
    ReadingTimerWidgetAttributes.ContentState.starEyes
}
