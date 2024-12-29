//
//  StatsScreen.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 10/12/2024.
//

import SwiftUI
import WidgetKit

struct StatsScreen: View {
    @StateObject private var viewModel = ReadingHoursViewModel()
    @StateObject private var bookViewModel = BookViewModel()
    @State private var selectedTimeframe: Timeframe = .week
    @State private var timerStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var isPaused = false
    
    
    var body: some View {
            NavigationStack {
                ZStack {
                    Color.softBackground.ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Timeframe Picker
                            Picker("Timeframe", selection: $selectedTimeframe) {
                                Text("Day").tag(Timeframe.day)
                                Text("Week").tag(Timeframe.week)
                                Text("Month").tag(Timeframe.month)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            
                            // Total Hours Summary
                            totalHoursSummary
                            
                            // Most Read Book Card 
                            mostReadBookCard
                            
                            // Timer Control Buttons
                            timerControlButtons
                            
                            // Expanded Graph
                            expandedGraph
                            
                            // Detailed Entries List
                            entriesList
                        }
                        .padding()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Reading Statistics")
                            .font(.custom("RobotoCondensed-Bold", size: 22))
                            .foregroundColor(.textPrimary)
                    }
                }
            }
        }
        
        private var timerControlButtons: some View {
            Group {
                if let mostReadBook = bookViewModel.getMostReadBook() {
                    HStack(spacing: 20) {
                        // Start Timer Button
                        Button(action: {
                            startTimer(for: mostReadBook)
                        }) {
                            Text("Start Timer")
                                .font(.custom("RobotoCondensed-Bold", size: 14))
                                .foregroundColor(.textPrimary)
                                .frame(width: 150, height: 40)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        
                        // Stop Timer Button
                        Button(action: {
                            stopTimer(for: mostReadBook)
                        }) {
                            Text("Stop Timer")
                                .font(.custom("RobotoCondensed-Bold", size: 14))
                                .foregroundColor(.textPrimary)
                                .frame(width: 150, height: 40)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                } else {
                    EmptyView()
                }
            }
        }
    
    private var mostReadBookCard: some View {
        Group {
            if let mostReadBook = bookViewModel.getMostReadBook() {
                NavigationLink(destination: ReadingTimerView(book: mostReadBook, viewModel: bookViewModel)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Currently reading")
                                .font(.custom("RobotoCondensed-Bold", size: 18))
                                .foregroundColor(.textSecondary)
                            
                            HStack(spacing: 15) {
                                // Book Cover
                                if let imageData = mostReadBook.coverImage, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 150)
                                        .cornerRadius(10)
                                } else {
                                    Image(systemName: "book.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 150)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(mostReadBook.title)
                                            .font(.custom("RobotoCondensed-Bold", size: 18))
                                            .foregroundColor(.textPrimary)
                                        
                                        Text(mostReadBook.author)
                                            .font(.custom("RobotoCondensed-Regular", size: 16))
                                            .foregroundColor(.textSecondary)
                                    }
                                    
                                    Text("Current Reading Time")
                                        .font(.custom("RobotoCondensed-Bold", size: 14))
                                        .foregroundColor(.textSecondary)
                                    
                                    Text(isTimerRunning ? timerDisplayText : formatReadingTime(mostReadBook.totalReadingTime))
                                        .font(.custom("RobotoCondensed-Bold", size: 24))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.textSecondary)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .padding()
                    .frame(minHeight: 200)
                    .frame(minWidth: 350)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
            } else {
                EmptyView()
            }
        }
    }






        
        private func formatReadingTime(_ time: Double) -> String {
            let hours = Int(time)
            let minutes = Int((time - Double(hours)) * 60)
            return "\(hours) hrs \(minutes) mins"
        }
    
    
    private var timerDisplayText: String {
           let hours = Int(elapsedTime) / 3600
           let minutes = (Int(elapsedTime) % 3600) / 60
           let seconds = Int(elapsedTime) % 60
           return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
       }
        
    private func pauseTimer() {
        guard isTimerRunning else { return }
        
        // Invalidate the current timer
        timer?.invalidate()
        timer = nil
        
        // Store the current time that has elapsed 
        isPaused = true
        isTimerRunning = false
    }

    // Modify the startTimer method to handle paused state
    private func startTimer(for book: Book) {
        guard !isTimerRunning else { return }
        
        if isPaused {
            timerStartTime = Date().addingTimeInterval(-elapsedTime)
            isPaused = false
        } else {
            timerStartTime = Date()
        }
        
        isTimerRunning = true
        bookViewModel.currentlyReadingBook = book
        
        // Save book title and timer start time to shared UserDefaults
        let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
        defaults.set(book.title, forKey: "mostReadBookTitle")
        defaults.set(timerStartTime, forKey: "timerStartTime")
        defaults.set(true, forKey: "isTimerRunning")
        
        // Reload widget and control widget timelines
        WidgetCenter.shared.reloadTimelines(ofKind: "ReadingTimerWidget")
        
        // Timer to update elapsed time
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let startTime = timerStartTime else { return }
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }

    private func stopTimer(for book: Book) {
        guard (isTimerRunning || isPaused), let startTime = timerStartTime else { return }
        
        timer?.invalidate()
        timer = nil
        
        let totalElapsedTime = Date().timeIntervalSince(startTime)
        let elapsedHours = totalElapsedTime / 3600
        
        bookViewModel.updateBookReadingTime(book, time: elapsedHours)
        
        // Clear timer start time, but keep book title
        let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
        defaults.removeObject(forKey: "timerStartTime")
        defaults.set(false, forKey: "isTimerRunning")
        
        // Reload widget and control widget timelines
        WidgetCenter.shared.reloadTimelines(ofKind: "ReadingTimerWidget")
        
        timerStartTime = nil
        elapsedTime = 0
        isTimerRunning = false
        isPaused = false
    }



    
    private var totalHoursSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Reading Time")
                .font(.custom("RobotoCondensed-Bold", size: 18))
                .foregroundColor(.textSecondary)
            
            HStack {
                Text(formattedTotalTime)
                    .font(.custom("RobotoCondensed-Bold", size: 36))
                    .foregroundColor(.textPrimary)
            }
            
            // Additional insights
            additionalInsights
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var formattedTotalTime: String {
        let totalHours = viewModel.totalHoursForTimeframe(selectedTimeframe)
        let hours = Int(totalHours)
        let minutes = Int((totalHours - Double(hours)) * 60)
        
        return "\(hours) hrs \(minutes) mins"
    }
    
    private var entriesList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reading Sessions")
                .font(.custom("RobotoCondensed-Bold", size: 18))
                .foregroundColor(.textSecondary)
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.entriesForTimeframe(selectedTimeframe)) { entry in
                        HStack {
                            Text(entry.date, style: .date)
                                .font(.custom("RobotoCondensed-Bold", size: 16))
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            Text(formatEntryTime(entry))
                                .font(.custom("RobotoCondensed-Bold", size: 16))
                                .foregroundColor(.accentTeal)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
    }
    
    private func formatEntryTime(_ entry: ReadingHoursEntry) -> String {
        let hours = Int(entry.hours)
        let minutes = Int((entry.hours - Double(hours)) * 60)
        return "\(hours) hrs \(minutes) mins"
    }
    
    private var additionalInsights: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Average Daily")
                    .font(.custom("RobotoCondensed-Bold", size: 12))
                    .foregroundColor(.textSecondary)
                
                Text(averageDailyHours)
                    .font(.custom("RobotoCondensed-Bold", size: 16))
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Longest Session")
                    .font(.custom("RobotoCondensed-Bold", size: 12))
                    .foregroundColor(.textSecondary)
                
                Text(longestSessionHours)
                    .font(.custom("RobotoCondensed-Bold", size: 16))
                    .foregroundColor(.textPrimary)
            }
        }
    }
    
    private var averageDailyHours: String {
        let entries = viewModel.entriesForTimeframe(selectedTimeframe)
        guard !entries.isEmpty else { return "0.0" }
        
        let totalHours = entries.reduce(0) { $0 + $1.hours }
        let daysCount = Set(entries.map { Calendar.current.component(.day, from: $0.date) }).count
        
        return String(format: "%.1f", totalHours / Double(max(daysCount, 1)))
    }
    
    private var longestSessionHours: String {
        let entries = viewModel.entriesForTimeframe(selectedTimeframe)
        let longestSession = entries.max { $0.hours < $1.hours }
        return String(format: "%.1f", longestSession?.hours ?? 0.0)
    }
    
    private var expandedGraph: some View {
        SimpleAxisLineGraph(data: chartData, timeframe: selectedTimeframe)
            .frame(height: 300)
            .padding()
    }
    
    private var chartData: [Double] {
        let entries = viewModel.entriesForTimeframe(selectedTimeframe)
        
        switch selectedTimeframe {
        case .day:
            return entries.map { $0.hours }
        case .week:
            let calendar = Calendar.current
            var weekData = Array(repeating: 0.0, count: 7)
            
            for entry in entries {
                let dayIndex = calendar.component(.weekday, from: entry.date) - 1
                weekData[dayIndex] += entry.hours
            }
            
            return weekData
        case .month:
            let calendar = Calendar.current
            var monthData = Array(repeating: 0.0, count: calendar.numberOfDaysInMonth(Date()))
            
            for entry in entries {
                let dayIndex = calendar.component(.day, from: entry.date) - 1
                monthData[dayIndex] += entry.hours
            }
            
            return monthData
        }
    }
}

#Preview {
    StatsScreen()
}


