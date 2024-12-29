//
//  ReadingTimerWidget.swift
//  ReadingTimerWidget
//
//  Created by arslaan ahmed on 21/12/2024.
//

import WidgetKit
import SwiftUI
import Foundation
import Intents
import UIKit


// Entry struct representing the widget's timeline entry
struct ReadingTimerEntry: TimelineEntry, Codable, Hashable {
    let date: Date
    let bookTitle: String
    let bookAuthor: String
    let totalReadingTime: Double
    let coverImageData: Data?
}

// Provider responsible for generating timeline entries
struct Provider: TimelineProvider {
    typealias Entry = ReadingTimerEntry

    func placeholder(in context: Context) -> ReadingTimerEntry {
        ReadingTimerEntry(
            date: Date(),
            bookTitle: "Sample Book",
            bookAuthor: "Author Name",
            totalReadingTime: 1.5,
            coverImageData: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ReadingTimerEntry) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
        
        let entry = ReadingTimerEntry(
            date: Date(),
            bookTitle: defaults.string(forKey: "mostReadBookTitle") ?? "No Book",
            bookAuthor: defaults.string(forKey: "mostReadBookAuthor") ?? "",
            totalReadingTime: defaults.double(forKey: "mostReadBookTotalTime"),
            coverImageData: defaults.data(forKey: "mostReadBookCoverImage")
        )
        
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReadingTimerEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
        
        let entry = ReadingTimerEntry(
            date: Date(),
            bookTitle: defaults.string(forKey: "mostReadBookTitle") ?? "No Book",
            bookAuthor: defaults.string(forKey: "mostReadBookAuthor") ?? "",
            totalReadingTime: defaults.double(forKey: "mostReadBookTotalTime"),
            coverImageData: defaults.data(forKey: "mostReadBookCoverImage")
        )
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// Widget configuration
struct ReadingTimerWidget: Widget {
    let kind: String = "ReadingTimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            ReadingTimerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Most Read Book")
        .description("Display your most read book")
        .supportedFamilies([.systemMedium])
    }
}

// Widget entry view
struct ReadingTimerWidgetEntryView: View {
    var entry: ReadingTimerEntry

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 15) {
                    // Book Cover
                    if let imageData = entry.coverImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 120)
                            .cornerRadius(8)
                    } else {
                        Image(systemName: "book.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 120)
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.bookTitle)
                            .font(.headline)
                            .lineLimit(2)

                        Text(entry.bookAuthor)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)

                        Text("Total Reading Time")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(formatReadingTime(entry.totalReadingTime))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding()

                // Chapterlylogo in top right corner
                Image("Chapterlylogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.blue)
                    .opacity(0.7)
                    .padding(8)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    // Helper method to format reading time
    private func formatReadingTime(_ time: Double) -> String {
        let hours = Int(time)
        let minutes = Int((time - Double(hours)) * 60)
        return "\(hours) hrs \(minutes) mins"
    }
}


// Preview
#Preview(as: .systemMedium) {
    ReadingTimerWidget()
} timeline: {
    ReadingTimerEntry(
        date: Date(),
        bookTitle: "The Great Gatsby",
        bookAuthor: "F. Scott Fitzgerald",
        totalReadingTime: 2.5,
        coverImageData: nil
    )
}

