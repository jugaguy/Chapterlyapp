//
//  ContentView.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 15/11/2024.
//

import SwiftUI
import WidgetKit
import Foundation
import CoreData


class StreakManager {
    static let shared = StreakManager()
    
    private let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
    
    private let streakKey = "dailyStreak"
    private let lastLoginDateKey = "lastLoginDate"
    
    var currentStreak: Int {
        get {
            return defaults.integer(forKey: streakKey)
        }
        set {
            defaults.set(newValue, forKey: streakKey)
        }
    }
    
    func updateStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastLoginDate = defaults.object(forKey: lastLoginDateKey) as? Date {
            // Calculate hours since last login
            let hoursSinceLastLogin = calendar.dateComponents([.hour], from: lastLoginDate, to: today).hour ?? 24
            
            if hoursSinceLastLogin > 24 {
                // If more than 24 hours have passed, reset streak to 0
                currentStreak = 0
            } else if !calendar.isDate(today, inSameDayAs: lastLoginDate) {
                // If it's a new day (but within 24 hours), increment streak
                currentStreak += 1
            }
        } else {
            // First login
            currentStreak = 1
        }
        
        // Always update the last login date
        defaults.set(today, forKey: lastLoginDateKey)
    }
    
    // Optional: Method to check if streak is valid
    func isStreakValid() -> Bool {
        guard let lastLoginDate = defaults.object(forKey: lastLoginDateKey) as? Date else {
            return false
        }
        
        let calendar = Calendar.current
        let hoursSinceLastLogin = calendar.dateComponents([.hour], from: lastLoginDate, to: Date()).hour ?? 24
        
        return hoursSinceLastLogin <= 24
    }
}


class StreakViewModel: ObservableObject {
    @Published var currentStreak: Int = 0
    
    init() {
        loadStreak()
    }
    
    func loadStreak() {
        currentStreak = StreakManager.shared.currentStreak
    }
    
    func updateStreak() {
        StreakManager.shared.updateStreak()
        currentStreak = StreakManager.shared.currentStreak
        
        // Optional: Reload the widget
        WidgetCenter.shared.reloadTimelines(ofKind: "StreakWidget")
    }
}





// Enhanced Color Palette
extension Color {
    static let accentTeal = Color(red: 0.0, green: 0.8, blue: 0.8)
    static let softBackground = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let cardBackground = Color.white
    static let textPrimary = Color.black.opacity(0.87)
    static let textSecondary = Color.black.opacity(0.6)
}

struct ReadingHoursEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let hours: Double
    let minutes: Double
}

enum Timeframe {
    case day, week, month
}

class ReadingHoursViewModel: ObservableObject {
    @Published var entries: [ReadingHoursEntry] = []
    @Published var newHours: String = ""
    @Published var newMinutes: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let entriesKey = "readingHoursEntries"
    
    init() {
        loadEntries()
    }
    
    func addHours() {
        let hours = Double(newHours) ?? 0
        let minutes = Double(newMinutes) ?? 0
        let totalHours = hours + (minutes / 60)
        
        guard totalHours > 0 else { return }
        
        let newEntry = ReadingHoursEntry(
            id: UUID(),
            date: Date(),
            hours: totalHours,
            minutes: minutes
        )
        
        entries.append(newEntry)
        saveEntries()
        
        newHours = ""
        newMinutes = ""
    }
    
    func entriesForTimeframe(_ timeframe: Timeframe) -> [ReadingHoursEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        return entries.filter { entry in
            switch timeframe {
            case .day:
                return calendar.isDate(entry.date, inSameDayAs: now)
            case .week:
                return calendar.dateComponents([.weekOfYear], from: entry.date, to: now).weekOfYear == 0
            case .month:
                return calendar.dateComponents([.month], from: entry.date, to: now).month == 0
            }
        }
    }
    
    func totalHoursForTimeframe(_ timeframe: Timeframe) -> Double {
        entriesForTimeframe(timeframe).reduce(0) { $0 + $1.hours }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: entriesKey)
        }
    }
    
    private func loadEntries() {
        if let savedEntries = userDefaults.object(forKey: entriesKey) as? Data {
            if let decodedEntries = try? JSONDecoder().decode([ReadingHoursEntry].self, from: savedEntries) {
                entries = decodedEntries
            }
        }
    }
}

struct ReadingHoursTrackerView: View {
    @StateObject private var viewModel = ReadingHoursViewModel()
    @State private var selectedTimeframe: Timeframe = .week
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("Hours", text: $viewModel.newHours)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .foregroundColor(.textPrimary)
                    .frame(width: 70)
                
                Text("hrs")
                    .foregroundColor(.textSecondary)
                    .font(.custom("RobotoCondensed-Bold", size: 16))
                
                TextField("Minutes", text: $viewModel.newMinutes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .foregroundColor(.textPrimary)
                    .frame(width: 70)
                
                Text("mins")
                    .foregroundColor(.textSecondary)
                    .font(.custom("RobotoCondensed-Bold", size: 16))
                
                Button(action: viewModel.addHours) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentTeal)
                        .font(.system(size: 24))
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Picker("Timeframe", selection: $selectedTimeframe) {
                Text("Day").tag(Timeframe.day)
                Text("Week").tag(Timeframe.week)
                Text("Month").tag(Timeframe.month)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            HStack {
                Text("Total Reading Time:")
                    .foregroundColor(.textSecondary)
                    .font(.custom("RobotoCondensed-Bold", size: 16))
                
                Text(formattedTotalTime)
                    .font(.custom("RobotoCondensed-Bold", size: 16))
                    .foregroundColor(.accentTeal)
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.entriesForTimeframe(selectedTimeframe)) { entry in
                        HStack {
                            Text(entry.date, style: .date)
                                .foregroundColor(.textPrimary)
                                .font(.custom("RobotoCondensed-Bold", size: 16))
                            Spacer()
                            Text(formattedEntryTime(entry))
                                .foregroundColor(.accentTeal)
                                .font(.custom("RobotoCondensed-Bold", size: 16))
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .background(Color.softBackground)
            .frame(maxHeight: 300)
        }
        .padding()
        .background(Color.softBackground)
    }
    
    private var formattedTotalTime: String {
        let totalHours = viewModel.totalHoursForTimeframe(selectedTimeframe)
        let hours = Int(totalHours)
        let minutes = Int((totalHours - Double(hours)) * 60)
        return "\(hours) hrs \(minutes) mins"
    }
    
    private func formattedEntryTime(_ entry: ReadingHoursEntry) -> String {
        let hours = Int(entry.hours)
        let minutes = Int((entry.hours - Double(hours)) * 60)
        return "\(hours) hrs \(minutes) mins"
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

extension Calendar {
    func numberOfDaysInMonth(_ date: Date) -> Int {
        return range(of: .day, in: .month, for: date)?.count ?? 0
    }
}

enum ColorSchemeManager {
    static func toggleColorScheme(_ colorScheme: Binding<ColorScheme?>) {
        switch colorScheme.wrappedValue {
        case .dark:
            colorScheme.wrappedValue = .light
        case .light:
            colorScheme.wrappedValue = .dark
        case .none:
            colorScheme.wrappedValue = .dark
        @unknown default:
            colorScheme.wrappedValue = .dark
        }
    }
}

struct MainScreen: View {
    @StateObject private var viewModel = BookViewModel()
    @State private var selectedTab = 0
    
    
    @State private var isCurrentlyReadingExpanded = false
    @State private var isJournalEntriesExpanded = false
    @State private var isWishlistExpanded = false
    @State private var isReadingHoursExpanded = false
    
    private var libraryCount: Int {
        viewModel.books.filter { $0.status == .library }.count
    }
    
    private var toBeReadCount: Int {
        viewModel.books.filter { $0.status == .toBeRead }.count
    }
    
    private var completedCount: Int {
        viewModel.books.filter { $0.status == .read }.count
    }
    
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ZStack {
                    Color.softBackground.ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            topIconsSection
                            titleSection
                            statsGridSection
                            currentlyReadingSection
                            journalEntriesSection
                            wishlistSection
                            readingHoursSection
                        }
                        .padding()
                    }
                }
                .sheet(isPresented: $viewModel.showingAddBook) {
                    AddBookView(viewModel: viewModel)
                }
                .sheet(isPresented: $viewModel.showingScanner) {
                    ScannerView(viewModel: viewModel)
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
                    .font(.custom("RobotoCondensed-Bold", size: 12))
            }
            .tag(0)
            
            // Stats Tab
            NavigationStack {
                ZStack {
                    Color.softBackground.ignoresSafeArea()
                    StatsScreen()
                }
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Stats")
                    .font(.custom("RobotoCondensed-Bold", size: 12))
            }
            .tag(1)
            
            // Library Tab
            NavigationStack {
                ZStack {
                    Color.softBackground.ignoresSafeArea()
                    JournalScreen()
                }
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Journals")
                    .font(.custom("RobotoCondensed-Bold", size: 12))
            }
            .tag(2)
            
            // Settings Tab
            NavigationStack {
                ZStack {
                    Color.softBackground.ignoresSafeArea()
                    SettingsScreen(viewModel: viewModel)
                }
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
                    .font(.custom("RobotoCondensed-Bold", size: 12))
            }
            .tag(3)
        }
                .accentColor(.accentTeal)
                .onAppear {
                    let appearance = UITabBarAppearance()
                    appearance.backgroundColor = .white
                    StreakManager.shared.updateStreak()
                    
                    appearance.stackedLayoutAppearance.normal.iconColor = .gray
                    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                        .foregroundColor: UIColor.gray,
                        .font: UIFont(name: "RobotoCondensed-Bold", size: 12) ?? UIFont.systemFont(ofSize: 12)
                    ]
                    
                    // Change these to use accentTeal
                    appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "accentTeal") ?? .systemTeal
                    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                        .foregroundColor: UIColor(named: "accentTeal") ?? .systemTeal
                    ]
                    
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }

        }
        
        struct ExpandableSection: View {
            let title: String
            let icon: String
            @Binding var isExpanded: Bool
            let content: () -> AnyView
            
            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: icon)
                                .foregroundColor(.textPrimary)
                            
                            Text(title)
                                .foregroundColor(.textPrimary)
                                .font(.custom("RobotoCondensed-Bold", size: 18))
                            
                            
                            Spacer()
                            
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    if isExpanded {
                        content()
                    }
                }
            }
        }
        
        private var topIconsSection: some View {
            HStack {
                Spacer()
                HStack(spacing: 20) {
                    Menu {
                        Button {
                            viewModel.showingAddBook = true
                        } label: {
                            Label("Add Manually", systemImage: "square.and.pencil")
                                .font(.custom("RobotoCondensed-Bold", size: 16))
                        }
                        Button {
                            viewModel.showingScanner = true
                        } label: {
                            Label("Scan Book", systemImage: "barcode.viewfinder")
                                .font(.custom("RobotoCondensed-Bold", size: 16))
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.textPrimary)
                            .font(.system(size: 20))
                    }
                }
            }
        }
        
        private var titleSection: some View {
            HStack(alignment: .center, spacing: 10) {
                Image("Chapterlylogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                
                Text("Chapterly")
                    .font(.custom("RobotoCondensed-Bold", size: 30))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(y: 8)
                    .offset(x: -10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
    private var statsGridSection: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                StatButton(title: "ALL", count: viewModel.books.count, viewModel: viewModel)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                StatButton(title: "Library", count: libraryCount, viewModel: viewModel)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            HStack(spacing: 15) {
                StatButton(title: "To Be Read", count: toBeReadCount, viewModel: viewModel)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                StatButton(title: "Completed", count: completedCount, viewModel: viewModel)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            // New Streak Card
            StreakCard(viewModel: viewModel)
            
            NavigationLink(destination: AudioBooksSection(viewModel: viewModel)) {
                Text("Your AudioBooks")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 13)
                    .padding()
                    .background(Color.black.opacity(1.0))
                    .cornerRadius(5)
                    .font(.custom("RobotoCondensed-Bold", size: 16))
            }
        }
    }

    // New Streak Card View
    struct StreakCard: View {
        @StateObject private var streakViewModel = StreakViewModel()
        @State private var showRecommendations = false
        @ObservedObject var viewModel: BookViewModel
        
        var body: some View {
            NavigationLink(destination: RecommendationScreen(viewModel: viewModel), isActive: $showRecommendations) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 24))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reading Streak")
                            .font(.custom("RobotoCondensed-Bold", size: 16))
                            .foregroundColor(.textPrimary)
                        
                        Text("\(streakViewModel.currentStreak) Days")
                            .font(.custom("RobotoCondensed-Bold", size: 24))
                            .foregroundColor(.accentTeal)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.textSecondary)
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .onAppear {
                streakViewModel.updateStreak()
            }
        }
    }



        
    private var currentlyReadingSection: some View {
        ExpandableSection(
            title: "Currently Reading",
            icon: "bookmark.fill",
            isExpanded: $isCurrentlyReadingExpanded
        ) {
            if viewModel.books.filter({ $0.status == .library }).isEmpty {
                return AnyView(
                    Text("No books in progress")
                        .font(.custom("RobotoCondensed-Bold", size: 16))
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                )
            } else {
                return AnyView(
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.books.filter { $0.status == .library }, id: \.id) { book in
                                VStack {
                                    if let imageData = book.coverImage, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 120, height: 180)
                                            .cornerRadius(10)
                                    } else {
                                        Image(systemName: "book.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 120, height: 180)
                                            .foregroundColor(.gray)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                    
                                    Text(book.title)
                                        .font(.caption)
                                        .foregroundColor(.textPrimary)
                                        .lineLimit(1)
                                }
                                .frame(width: 120)
                            }
                        }
                    }
                )
            }
        }
    }

        
        private var journalEntriesSection: some View {
            ExpandableSection(
                title: "Journal Entries",
                icon: "note.text",
                isExpanded: $isJournalEntriesExpanded
            ) {
                if viewModel.books.filter({ $0.notes?.isEmpty == false }).isEmpty {
                    return AnyView(
                        Text("No journal entries yet")
                            .font(.custom("RobotoCondensed-Bold", size: 16))
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity)
                    )
                } else {
                    return AnyView(
                        VStack(spacing: 10) {
                            ForEach(viewModel.books.filter { $0.notes?.isEmpty == false }, id: \.id) { book in
                                NavigationLink(destination: BookNotesView(book: book, viewModel: viewModel)) {
                                    HStack {
                                        Text(book.title)
                                            .foregroundColor(.textPrimary)
                                        Spacer()
                                        Text(book.notes?.components(separatedBy: .newlines).first ?? "")
                                            .foregroundColor(.textSecondary)
                                    }
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                    )
                }
            }
        }
        
        private var wishlistSection: some View {
            ExpandableSection(
                title: "Wishlist",
                icon: "heart.fill",
                isExpanded: $isWishlistExpanded
            ) {
                if viewModel.books.filter({ $0.status == .wishlist }).isEmpty {
                    return AnyView(
                        Text("No books in wishlist")
                            .font(.custom("RobotoCondensed-Bold", size: 16))
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity)
                    )
                } else {
                    return AnyView(
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.books.filter { $0.status == .wishlist }, id: \.id) { book in
                                    VStack(alignment: .leading) {
                                        if let imageData = book.coverImage, let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 120, height: 180)
                                                .cornerRadius(10)
                                        } else {
                                            Image(systemName: "book.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 120, height: 180)
                                                .foregroundColor(.gray)
                                                .background(Color.white.opacity(0.1))
                                                .cornerRadius(10)
                                        }
                                        
                                        Text(book.title)
                                            .font(.custom("RobotoCondensed-Bold", size: 14))
                                            .foregroundColor(.textPrimary)
                                            .lineLimit(1)
                                        
                                        Text(book.author)
                                            .font(.custom("RobotoCondensed-Bold", size: 12))
                                            .foregroundColor(.textSecondary)
                                            .lineLimit(1)
                                        
                                        Text("$\(String(format: "%.2f", book.price ?? 0.0))")
                                            .font(.custom("RobotoCondensed-Bold", size: 12))
                                            .foregroundColor(.green)
                                    }
                                    .frame(width: 120)
                                }
                            }
                        }
                    )
                }
            }
        }
        
        private var readingHoursSection: some View {
            ExpandableSection(
                title: "Reading Hours",
                icon: "clock.fill",
                isExpanded: $isReadingHoursExpanded
            ) {
                return AnyView(
                    ReadingHoursTrackerView()
                )
            }
        }
        
        
        
        struct StatButton: View {
            let title: String
            let count: Int
            @ObservedObject var viewModel: BookViewModel
            
            var body: some View {
                NavigationLink(destination: destinationView) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.custom("RobotoCondensed-Bold", size: 16))
                            .foregroundColor(.textSecondary)
                        
                        Text("\(count)")
                            .font(.custom("RobotoCondensed-Bold", size: 36))
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
            
            private var destinationView: some View {
                Group {
                    switch title {
                    case "ALL":
                        BookSection(title: "All Books", books: viewModel.books, viewModel: viewModel)
                    case "Library":
                        LibrarySection(viewModel: viewModel)
                    case "To Be Read":
                        ToBeReadSection(viewModel: viewModel)
                    case "Completed":
                        CompletedSection(viewModel: viewModel)
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
    
    struct SimpleAxisLineGraph: View {
        let data: [Double]
        let timeframe: Timeframe
        
        private let graphHeight: CGFloat = 250
        private let graphWidth: CGFloat = 300
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Color.softBackground.ignoresSafeArea()
                    
                    VStack {
                        graphContainer
                    }
                }
            }
        }
        
        private var graphContainer: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                VStack {
                    graphContent
                    xAxisLabels
                }
                .padding()
            }
            .frame(height: graphHeight)
        }
        
        private var graphContent: some View {
            GeometryReader { geometry in
                ZStack {
                    gridLines(in: geometry)
                    linePath(in: geometry)
                    dataPoints(in: geometry)
                }
            }
        }
        
        private func gridLines(in geometry: GeometryProxy) -> some View {
            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    Path { path in
                        let y = geometry.size.height * CGFloat(index) / 4
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.textSecondary.opacity(0.2), lineWidth: 1)
                }
            }
        }
        
        private func linePath(in geometry: GeometryProxy) -> some View {
            Path { path in
                guard !data.isEmpty else { return }
                
                let maxValue = data.max() ?? 0
                
                path.move(to: CGPoint(
                    x: 0,
                    y: geometry.size.height - (CGFloat(data[0]) / CGFloat(maxValue)) * geometry.size.height
                ))
                
                for (index, value) in data.enumerated().dropFirst() {
                    let x = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
                    let y = geometry.size.height - (CGFloat(value) / CGFloat(maxValue)) * geometry.size.height
                    
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.accentTeal, lineWidth: 2)
        }
        
        private func dataPoints(in geometry: GeometryProxy) -> some View {
            ForEach(data.indices, id: \.self) { index in
                let maxValue = data.max() ?? 0
                let x = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
                let y = geometry.size.height - (CGFloat(data[index]) / CGFloat(maxValue)) * geometry.size.height
                
                Circle()
                    .fill(Color.accentTeal)
                    .frame(width: 8, height: 8)
                    .position(x: x, y: y)
            }
        }
        
        private var xAxisLabels: some View {
            HStack {
                ForEach(xAxisLabelTexts.indices, id: \.self) { index in
                    Text(xAxisLabelTexts[index])
                    Text(xAxisLabelTexts[index])
                        .font(.custom("RobotoCondensed-Bold", size: 12))
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        
        private var xAxisLabelTexts: [String] {
            switch timeframe {
            case .day:
                return ["00:00", "06:00", "12:00", "18:00", "24:00"]
            case .week:
                return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            case .month:
                return ["1", "6", "11", "16", "21", "26", "31"]
            }
        }
    }
    
    struct SimpleLinesGraph: View {
        let data: [Double]
        let maxHeight: CGFloat = 200
        let maxWidth: CGFloat = 300
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    gridLines
                    graphPath
                    dataPoints
                }
                .frame(height: maxHeight)
                .background(Color.cardBackground)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.textSecondary.opacity(0.2), lineWidth: 1)
                )
            }
        }
        
        private var gridLines: some View {
            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    Path { path in
                        let x = maxWidth * CGFloat(index) / 4
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: maxHeight))
                    }
                    .stroke(Color.textSecondary.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5]))
                }
                
                ForEach(0..<5, id: \.self) { index in
                    Path { path in
                        let y = maxHeight * CGFloat(index) / 4
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: maxWidth, y: y))
                    }
                    .stroke(Color.textSecondary.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5]))
                }
            }
        }
        
        private var graphPath: some View {
            GeometryReader { geometry in
                Path { path in
                    guard data.count > 1 else { return }
                    
                    let maxValue = data.max() ?? 1
                    
                    path.move(to: CGPoint(
                        x: 0,
                        y: maxHeight - (CGFloat(data[0]) / CGFloat(maxValue)) * maxHeight
                    ))
                    
                    for (index, value) in data.enumerated().dropFirst() {
                        let x = maxWidth * CGFloat(index) / CGFloat(data.count - 1)
                        let y = maxHeight - (CGFloat(value) / CGFloat(maxValue)) * maxHeight
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.accentTeal.opacity(0.7),
                            Color.accentTeal.opacity(0.4)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                .background(
                    Path { path in
                        guard data.count > 1 else { return }
                        
                        let maxValue = data.max() ?? 1
                        
                        path.move(to: CGPoint(x: 0, y: maxHeight))
                        
                        for (index, value) in data.enumerated() {
                            let x = maxWidth * CGFloat(index) / CGFloat(data.count - 1)
                            let y = maxHeight - (CGFloat(value) / CGFloat(maxValue)) * maxHeight
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        path.addLine(to: CGPoint(x: maxWidth, y: maxHeight))
                        path.closeSubpath()
                    }
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.accentTeal.opacity(0.3),
                                    Color.accentTeal.opacity(0.1),
                                    Color.accentTeal.opacity(0.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
            }
        }
        
        private var dataPoints: some View {
            GeometryReader { geometry in
                ForEach(data.indices, id: \.self) { index in
                    let maxValue = data.max() ?? 1
                    let x = maxWidth * CGFloat(index) / CGFloat(data.count - 1)
                    let y = maxHeight - (CGFloat(data[index]) / CGFloat(maxValue)) * maxHeight
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.accentTeal, lineWidth: 2)
                                .frame(width: 12, height: 12)
                        )
                        .position(x: x, y: y)
                }
            }
        }
    }
    
    #Preview {
        MainScreen()
    }

