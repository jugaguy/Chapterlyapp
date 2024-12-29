//
//  RecommendationScreen.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 17/12/2024.
//

import SwiftUI

// Hashable extension for GoogleBookItem
extension GoogleBookItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(volumeInfo.title)
        hasher.combine(volumeInfo.authors)
    }
    
    static func == (lhs: GoogleBookItem, rhs: GoogleBookItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.volumeInfo.title == rhs.volumeInfo.title &&
               lhs.volumeInfo.authors == rhs.volumeInfo.authors
    }
}

// Google Book Recommendation Card View
struct GoogleBookRecommendationCard: View {
    let book: GoogleBookItem
    let onAddToList: () -> Void
    @State private var isAdded = false
    
    var body: some View {
        HStack(spacing: 15) {
            bookCoverImage
            bookDetails
            addToListButton
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var bookCoverImage: some View {
        Group {
            if let urlString = book.volumeInfo.imageLinks?.thumbnail,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                } placeholder: {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 120)
                        .foregroundColor(.gray)
                }
            } else {
                Image(systemName: "book.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 120)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var bookDetails: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(book.volumeInfo.title)
                .font(.custom("RobotoCondensed-Bold", size: 18))
                .foregroundColor(.black)
            
            Text(book.volumeInfo.authors?.first ?? "Unknown Author")
                .font(.custom("RobotoCondensed-Regular", size: 14))
                .foregroundColor(.gray)
            
            if let category = book.volumeInfo.categories?.first {
                Text(category)
                    .font(.custom("RobotoCondensed-Regular", size: 12))
                    .foregroundColor(.accentTeal)
            }
        }
    }
    
    private var addToListButton: some View {
        Button(action: {
            onAddToList()
            isAdded = true
        }) {
            if isAdded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 30))
            } else {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.accentTeal)
                    .font(.system(size: 30))
            }
        }
        .disabled(isAdded)
    }
}

// Personalized Summary View
struct PersonalizedSummaryView: View {
    let genres: [String]
    let moods: [String]
    let recommendedBooks: [GoogleBookItem]
    @ObservedObject var viewModel: BookViewModel
    @Environment(\.presentationMode) var presentationMode
    let onDismiss: () -> Void
    @State private var isQuizReset = false
    
    @AppStorage("savedGenres") private var savedGenres: String = ""
    @AppStorage("savedMoods") private var savedMoods: String = ""
    @AppStorage("savedRecommendations") private var savedRecommendations: Data = Data()
    
    init(genres: [String], moods: [String], recommendedBooks: [GoogleBookItem], viewModel: BookViewModel, onDismiss: @escaping () -> Void) {
        self.genres = genres
        self.moods = moods
        self.recommendedBooks = recommendedBooks
        self.viewModel = viewModel
        self.onDismiss = onDismiss
        
        // Save the data when view is initialized
        savedGenres = genres.joined(separator: ",")
        savedMoods = moods.joined(separator: ",")
        
        if let encoded = try? JSONEncoder().encode(recommendedBooks) {
            savedRecommendations = encoded
        }
    }
    
    var body: some View {
        ZStack {
            Color.softBackground.ignoresSafeArea()
            
            if isQuizReset {
                RecommendationScreen(viewModel: viewModel)
            } else {
                ScrollView {
                    VStack(spacing: 25) {
                        // Header Section with Reset Button
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
                        .padding()
                        
                        // Favorite Genres Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Favorite Genres:")
                                .font(.custom("RobotoCondensed-Bold", size: 18))
                                .foregroundColor(.textPrimary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(genres, id: \.self) { genre in
                                        Text(genre)
                                            .font(.custom("RobotoCondensed-Bold", size: 14))
                                            .foregroundColor(.textPrimary)
                                            .padding()
                                            .background(Color.cardBackground)
                                            .cornerRadius(12)
                                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                        .padding()
                        
                        // Moods Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Reading Moods:")
                                .font(.custom("RobotoCondensed-Bold", size: 18))
                                .foregroundColor(.textPrimary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(moods, id: \.self) { mood in
                                        Text(mood)
                                            .font(.custom("RobotoCondensed-Bold", size: 14))
                                            .foregroundColor(.textPrimary)
                                            .padding()
                                            .background(Color.cardBackground)
                                            .cornerRadius(12)
                                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                        .padding()
                        
                        // Recommended Books Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Personalized Recommendations")
                                .font(.custom("RobotoCondensed-Bold", size: 18))
                                .foregroundColor(.textPrimary)
                            
                            if recommendedBooks.isEmpty {
                                Text("No recommendations found")
                                    .font(.custom("RobotoCondensed-Regular", size: 16))
                                    .foregroundColor(.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 15) {
                                        ForEach(recommendedBooks) { book in
                                            GoogleBookRecommendationCard(
                                                book: book,
                                                onAddToList: {
                                                    // Download image first, then create and add the book
                                                    downloadAndStoreBookImage(urlString: book.volumeInfo.imageLinks?.thumbnail) { imageData in
                                                        let newBook = Book(
                                                            title: book.volumeInfo.title,
                                                            author: book.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown",
                                                            description: book.volumeInfo.description ?? "",
                                                            coverImage: imageData,  // Pass the downloaded image data
                                                            status: .toBeRead,
                                                            price: book.saleInfo?.retailPrice?.amount
                                                        )
                                                        
                                                        // Ensure UI updates happen on the main queue
                                                        DispatchQueue.main.async {
                                                            viewModel.addBook(newBook)
                                                        }
                                                    }
                                                }
                                            )
                                        }
                                    }
                                    .padding()
                                }
                            }
                        }
                        .padding()
                        
                        Button(action: {
                            // Reset quiz completion flags
                            UserDefaults.standard.set(false, forKey: "hasCompletedRecommendationQuiz")
                            UserDefaults.standard.set(false, forKey: "hasViewedPersonalizedSummary")
                            
                            // Ensure the changes are saved immediately
                            UserDefaults.standard.synchronize()
                            
                            onDismiss()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Home")
                                .font(.custom("RobotoCondensed-Bold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        .padding()
                    }
                }
            }
        }
    }
    
    
    private func downloadAndStoreBookImage(urlString: String?, completion: @escaping (Data?) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to download book image: \(error)")
                completion(nil)
                return
            }
            
            // Ensure the downloaded data is a valid image
            if let data = data, UIImage(data: data) != nil {
                completion(data)
            } else {
                print("Invalid image data")
                completion(nil)
            }
        }.resume()
    }
}



struct RecommendationScreen: View {
    @State private var currentPage = 0
    @State private var selectedGenres: Set<String> = []
    @State private var selectedMoods: Set<String> = []
    @State private var readingFrequency: ReadingFrequency = .occasional
    @State private var recommendedBooks: [GoogleBookItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPersonalizedSummary = false
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BookViewModel
    
    // Persistent Storage
    @AppStorage("userSelectedGenres") private var storedGenres: String = ""
    @AppStorage("userSelectedMoods") private var storedMoods: String = ""
    @AppStorage("userReadingFrequency") private var storedReadingFrequency: String = ""
    @AppStorage("hasCompletedRecommendationQuiz") private var hasCompletedQuiz = false
    @AppStorage("hasViewedPersonalizedSummary") private var hasViewedPersonalizedSummary = false
    @AppStorage("storedRecommendedBooksData") private var storedRecommendedBooksData: String = ""
    @AppStorage("storedSelectedGenres") private var storedSelectedGenres: String = ""
    @AppStorage("storedSelectedMoods") private var storedSelectedMoods: String = ""
    
    // Expanded Genres and Moods
    let genres = [
        // Fiction
        "Fantasy", "Science Fiction", "Mystery", "Romance", "Historical Fiction",
        "Thriller", "Young Adult", "Literary Fiction",
        
        // Non-Fiction
        "Self Improvement", "Biography", "History", "Philosophy",
        "Science", "Psychology", "Business", "Technology",
        "Personal Development", "Leadership", "Economics",
        "Sociology", "Entrepreneurship"
    ]
    
    let moods = [
        "Inspirational", "Adventurous", "Relaxing", "Thought-Provoking",
        "Emotional", "Humorous", "Motivated", "Analytical",
        "Contemplative", "Empowering", "Strategic", "Innovative",
        "Challenging", "Transformative", "Introspective", "Meditative"
    ]
    
    enum ReadingFrequency: String, CaseIterable {
        case occasional = "Occasional Reader (1-2 books/month)"
        case regular = "Regular Reader (3-4 books/month)"
        case avid = "Avid Reader (5+ books/month)"
    }
    
    private var genreSelectionPage: some View {
        VStack(spacing: 20) {
            Text("Select Your Favorite Genres")
                .font(.custom("RobotoCondensed-Bold", size: 24))
                .foregroundColor(.black)
            
            Text("Choose up to 3 genres you enjoy")
                .font(.custom("RobotoCondensed-Regular", size: 16))
                .foregroundColor(.black)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                    ForEach(genres, id: \.self) { genre in
                        GenreChip(
                            genre: genre,
                            isSelected: selectedGenres.contains(genre)
                        ) {
                            if selectedGenres.contains(genre) {
                                selectedGenres.remove(genre)
                            } else if selectedGenres.count < 3 {
                                selectedGenres.insert(genre)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var moodSelectionPage: some View {
        VStack(spacing: 20) {
            Text("What's Your Reading Mood?")
                .font(.custom("RobotoCondensed-Bold", size: 24))
                .foregroundColor(.black)
            
            Text("Select up to 2 moods that describe your current reading preference")
                .font(.custom("RobotoCondensed-Regular", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                    ForEach(moods, id: \.self) { mood in
                        GenreChip(
                            genre: mood,
                            isSelected: selectedMoods.contains(mood)
                        ) {
                            if selectedMoods.contains(mood) {
                                selectedMoods.remove(mood)
                            } else if selectedMoods.count < 2 {
                                selectedMoods.insert(mood)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var readingFrequencyPage: some View {
        VStack(spacing: 20) {
            Text("How Often Do You Read?")
                .font(.custom("RobotoCondensed-Bold", size: 24))
                .foregroundColor(.black)
            
            VStack(spacing: 15) {
                ForEach(ReadingFrequency.allCases, id: \.self) { frequency in
                    FrequencyOptionView(
                        frequency: frequency,
                        isSelected: readingFrequency == frequency
                    ) {
                        readingFrequency = frequency
                    }
                }
            }
            .padding()
        }
    }
    
    var body: some View {
        // Always show the quiz if either flag is false
        if !hasCompletedQuiz || !hasViewedPersonalizedSummary {
            ZStack {
                Color.softBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    
                    Spacer()
                    
                    currentPageContent
                    
                    Spacer()
                    
                    navigationControls
                    
                    pageIndicatorView
                }
            }
            .onAppear(perform: loadSavedPreferences)
        } else {
            PersonalizedSummaryView(
                genres: Array(selectedGenres),
                moods: Array(selectedMoods),
                recommendedBooks: recommendedBooks,
                viewModel: viewModel,
                onDismiss: {
                    // Reset flags when dismissing
                    hasCompletedQuiz = false
                    hasViewedPersonalizedSummary = false
                    showPersonalizedSummary = false
                }
            )
        }
    }

    
    private var headerSection: some View {
        HStack(spacing: -10) {
            Image("Chapterlylogo")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
            
            Text("Chapterly")
                .font(.custom("RobotoCondensed-Bold", size: 24))
                .foregroundColor(.black)
                .offset(y: 10)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var welcomePage: some View {
        VStack(spacing: 20) {
            Image("ChapBook")
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
                .foregroundColor(.black)
            
            Text("Help us keep your reading streak alive!")
                .font(.custom("RobotoCondensed-Bold", size: 24))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            Text("Let's get an idea of the books you love most!.")
                .font(.custom("RobotoCondensed-Regular", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
        }
        .padding()
    }
    
    private var recommendationResultPage: some View {
        VStack(spacing: 20) {
            Text("Your Personalized Recommendations")
                .font(.custom("RobotoCondensed-Bold", size: 24))
                .foregroundColor(.black)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(recommendedBooks) { book in
                            GoogleBookRecommendationCard(
                                book: book,
                                onAddToList: { addBookToList(book) }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var navigationControls: some View {
        Button(action: navigateToNextPage) {
            Text(currentPage == 4 ? "Finish" : "Next")
                .font(.custom("RobotoCondensed-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
        }
        .padding()
        .disabled(shouldDisableNextButton)
    }
    
    private var currentPageContent: some View {
        Group {
            switch currentPage {
            case 0: welcomePage
            case 1: genreSelectionPage
            case 2: moodSelectionPage
            case 3: readingFrequencyPage
            case 4: recommendationResultPage
            default: EmptyView()
            }
        }
    }
    
    private var pageIndicatorView: some View {
        HStack {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.black : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.bottom)
    }
    
    private var shouldDisableNextButton: Bool {
        switch currentPage {
        case 1: return selectedGenres.isEmpty
        case 2: return selectedMoods.isEmpty
        default: return false
        }
    }
    
    private func navigateToNextPage() {
        withAnimation {
            switch currentPage {
            case 0:
                currentPage += 1
            case 1 where !selectedGenres.isEmpty:
                currentPage += 1
            case 2 where !selectedMoods.isEmpty:
                currentPage += 1
            case 3:
                fetchRecommendations()
                savePreferences()
                currentPage += 1
                
                // Set completion flags
                hasCompletedQuiz = true
                hasViewedPersonalizedSummary = false
            case 4:
                showPersonalizedSummary = true
                hasViewedPersonalizedSummary = true
            default:
                break
            }
        }
    }

    
    private func fetchRecommendations() {
        isLoading = true
        errorMessage = nil
        
        // Expand search query to include more diverse results
        let genreQueries = selectedGenres.map { $0.lowercased() }
        let moodQueries = selectedMoods.map { $0.lowercased() }
        
        // Combine genres and moods for more comprehensive search
        let combinedQueries = (genreQueries + moodQueries).joined(separator: "+")
        
        // Multiple search strategies
        let searchStrategies = [
            "https://www.googleapis.com/books/v1/volumes?q=\(combinedQueries)&maxResults=40",
            "https://www.googleapis.com/books/v1/volumes?q=subject:\(combinedQueries)&maxResults=40",
            "https://www.googleapis.com/books/v1/volumes?q=intitle:\(combinedQueries)&maxResults=40"
        ]
        
        // Perform multiple searches to increase recommendation diversity
        var allBooks: [GoogleBookItem] = []
        
        let dispatchGroup = DispatchGroup()
        
        for urlString in searchStrategies {
            guard let url = URL(string: urlString) else { continue }
            
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { dispatchGroup.leave() }
                
                guard let data = data else { return }
                
                do {
                    let result = try JSONDecoder().decode(GoogleBooksAPIResponse.self, from: data)
                    allBooks.append(contentsOf: result.items ?? [])
                } catch {
                    print("Decoding error: \(error)")
                }
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            // Remove duplicates
            let uniqueBooks = Array(Set(allBooks))
            
            // Rank and filter recommendations
            self.recommendedBooks = self.rankRecommendations(uniqueBooks)
            
            self.isLoading = false
            
            if self.recommendedBooks.isEmpty {
                self.errorMessage = "No recommendations found. Try adjusting your preferences."
            }
        }
    }
    
    private func rankRecommendations(_ books: [GoogleBookItem]) -> [GoogleBookItem] {
        return books
            .filter { book in
                // More comprehensive filtering
                let hasValidTitle = !(book.volumeInfo.title.isEmpty)
                let hasAuthors = !(book.volumeInfo.authors?.isEmpty ?? true)
                let hasReasonablePageCount = (book.volumeInfo.pageCount ?? 0) > 50
                let hasAcceptableRating = (book.volumeInfo.averageRating ?? 0) >= 3.0
                
                return hasValidTitle && hasAuthors && hasReasonablePageCount && hasAcceptableRating
            }
            .sorted { book1, book2 in
                // More sophisticated ranking
                let matchScore1 = calculateMatchScore(book: book1)
                let matchScore2 = calculateMatchScore(book: book2)
                
                if matchScore1 != matchScore2 {
                    return matchScore1 > matchScore2
                }
                
                // Secondary sorting by rating
                let rating1 = book1.volumeInfo.averageRating ?? 0
                let rating2 = book2.volumeInfo.averageRating ?? 0
                
                return rating1 > rating2
            }
            .prefix(20)
            .map { $0 }
    }
    
    private func calculateMatchScore(book: GoogleBookItem) -> Int {
        var score = 0
        
        // Match genres
        if let categories = book.volumeInfo.categories {
            for category in categories {
                if selectedGenres.contains(where: { category.lowercased().contains($0.lowercased()) }) {
                    score += 3
                }
            }
        }
        
        // Match moods
        let bookDescription = (book.volumeInfo.description ?? "").lowercased()
        for mood in selectedMoods {
            if bookDescription.contains(mood.lowercased()) {
                score += 2
            }
        }
        
        return score
    }
    
    
    private func downloadAndStoreBookImage(urlString: String?, completion: @escaping (Data?) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to download book image: \(error)")
                completion(nil)
                return
            }
            
            // Ensure the downloaded data is a valid image
            if let data = data, UIImage(data: data) != nil {
                completion(data)
            } else {
                print("Invalid image data")
                completion(nil)
            }
        }.resume()
    }

    
    private func addBookToList(_ book: GoogleBookItem) {
        // Download image first, then create and add the book
        downloadAndStoreBookImage(urlString: book.volumeInfo.imageLinks?.thumbnail) { imageData in
            let newBook = Book(
                title: book.volumeInfo.title,
                author: book.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown",
                description: book.volumeInfo.description ?? "",
                coverImage: imageData,  // Pass the downloaded image data
                status: .toBeRead,
                price: book.saleInfo?.retailPrice?.amount
            )
            
            // Ensure UI updates happen on the main queue
            DispatchQueue.main.async {
                viewModel.addBook(newBook)
            }
        }
    }
    
    // Add these functions to RecommendationScreen
    private func savePreferences() {
        // Save all user preferences
        UserDefaults.standard.set(Array(selectedGenres), forKey: "storedSelectedGenres")
        UserDefaults.standard.set(Array(selectedMoods), forKey: "storedSelectedMoods")
        
        if let encoded = try? JSONEncoder().encode(recommendedBooks) {
            UserDefaults.standard.set(encoded, forKey: "storedRecommendedBooks")
        }
        
        UserDefaults.standard.set(true, forKey: "hasCompletedRecommendationQuiz")
        UserDefaults.standard.synchronize()
    }

    private func loadSavedPreferences() {
        // Load saved preferences
        if let savedGenres = UserDefaults.standard.array(forKey: "storedSelectedGenres") as? [String] {
            selectedGenres = Set(savedGenres)
        }
        
        if let savedMoods = UserDefaults.standard.array(forKey: "storedSelectedMoods") as? [String] {
            selectedMoods = Set(savedMoods)
        }
        
        if let savedBooksData = UserDefaults.standard.data(forKey: "storedRecommendedBooks"),
           let decodedBooks = try? JSONDecoder().decode([GoogleBookItem].self, from: savedBooksData) {
            recommendedBooks = decodedBooks
        }
    }


    
    // Supporting Views
    struct FrequencyOptionView: View {
        let frequency: RecommendationScreen.ReadingFrequency
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(frequency.rawValue)
                        .font(.custom("RobotoCondensed-Bold", size: 16))
                        .foregroundColor(isSelected ? .white : .black)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(isSelected ? Color.black : Color.cardBackground)
                .cornerRadius(12)
            }
        }
    }
    
    struct GenreChip: View {
        let genre: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(genre)
                    .font(.custom("RobotoCondensed-Bold", size: 14))
                    .foregroundColor(isSelected ? .white : .black)
                    .padding()
                    .background(isSelected ? Color.black : Color.cardBackground)
                    .cornerRadius(20)
            }
        }
    }
    
    struct BookRecommendationCard: View {
        let book: Book
        let onAddToList: () -> Void
        
        var body: some View {
            HStack(spacing: 15) {
                bookCoverImage
                bookDetails
                addToListButton
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        
        private var bookCoverImage: some View {
            Group {
                if let imageData = book.coverImage, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 120)
                        .foregroundColor(.gray)
                }
            }
        }
        
        private var bookDetails: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text(book.title)
                    .font(.custom("RobotoCondensed-Bold", size: 18))
                    .foregroundColor(.textPrimary)
                
                Text(book.author)
                    .font(.custom("RobotoCondensed-Regular", size: 14))
                    .foregroundColor(.textSecondary)
                
                if let genre = book.genre?.rawValue {
                    Text(genre)
                        .font(.custom("RobotoCondensed-Regular", size: 12))
                        .foregroundColor(.accentTeal)
                }
            }
        }
        
        private var addToListButton: some View {
            Button(action: onAddToList) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.accentTeal)
                    .font(.system(size: 30))
            }
        }
    }
}

