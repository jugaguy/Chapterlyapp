//
//  AudioBooksSection.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 08/12/2024.
//

import SwiftUI
import Combine

struct AudiobookSearchResult: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let description: String
    let coverImageURL: String?
    let previewLink: String?
    let duration: String?
    
    init(
        id: String,
        title: String,
        author: String,
        description: String?,
        coverImageURL: String?,
        previewLink: String?,
        duration: String?
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.description = description ?? "No description available"
        self.coverImageURL = coverImageURL
        self.previewLink = previewLink
        self.duration = duration
    }
}

class AudiobookSearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [AudiobookSearchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] query in
                self?.searchAudiobooks(query: query)
            }
            .store(in: &cancellables)
    }
    
    func searchAudiobooks(query: String) {
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)+audiobook&maxResults=20") else {
            isLoading = false
            errorMessage = "Invalid search query"
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: GoogleBooksAPIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = "Search failed: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] response in
                self?.searchResults = response.items?.compactMap { item in
                    AudiobookSearchResult(
                        id: item.id,
                        title: item.volumeInfo.title,
                        author: item.volumeInfo.authors?.first ?? "Unknown Author",
                        description: item.volumeInfo.description,
                        coverImageURL: item.volumeInfo.imageLinks?.thumbnail,
                        previewLink: item.volumeInfo.previewLink,
                        duration: nil
                    )
                } ?? []
            })
            .store(in: &cancellables)
    }
}

struct AudiobookGridItem: View {
    let book: Book
    let isEditing: Bool
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                if let imageData = book.coverImage,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 150)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .rotation3DEffect(.degrees(isEditing ? 5 : 0),
                                       axis: (x: 10, y: 0, z: 0))
                        .animation(
                            isEditing ?
                            Animation.easeInOut(duration: 0.1)
                                .repeatForever(autoreverses: true) :
                                .default,
                            value: isEditing
                        )
                } else {
                    Image(systemName: "headphones")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 150)
                        .foregroundColor(.textSecondary)
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .rotation3DEffect(.degrees(isEditing ? 5 : 0),
                                       axis: (x: 10, y: 0, z: 0))
                        .animation(
                            isEditing ?
                            Animation.easeInOut(duration: 0.1)
                                .repeatForever(autoreverses: true) :
                                .default,
                            value: isEditing
                        )
                }
                
                Text(book.title)
                    .font(.custom("RobotoCondensed-Bold", size: 12))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
            }
            
            if isEditing {
                Button(action: {
                    withAnimation {
                        onDelete()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .background(Color.cardBackground.clipShape(Circle()))
                }
                .padding(5)
            }
        }
    }
}

struct AudioBooksSection: View {
    @ObservedObject var viewModel: BookViewModel
    @StateObject private var searchViewModel = AudiobookSearchViewModel()
    @State private var isEditing = false
    
    private var audiobooks: [Book] {
        viewModel.books.filter { $0.isAudiobook }
    }
    
    var body: some View {
        ZStack {
            Color.softBackground.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textSecondary)
                        
                        TextField("Search Audiobooks", text: $searchViewModel.searchQuery)
                            .font(.custom("RobotoCondensed-Bold", size: 16))
                            .foregroundColor(.textPrimary)
                            .accentColor(.accentTeal)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding()
                    
                    // Your Audiobooks Header with Edit/Cancel
                    HStack {
                        Text("Your Audiobooks")
                            .font(.custom("RobotoCondensed-Bold", size: 22))
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        if !audiobooks.isEmpty {
                            Button(action: {
                                withAnimation {
                                    isEditing.toggle()
                                }
                            }) {
                                Text(isEditing ? "Cancel" : "Edit")
                                    .font(.custom("RobotoCondensed-Bold", size: 16))
                                    .foregroundColor(.accentTeal)
                            }
                        }
                    }
                    .padding()
                    
                    // Local Audiobooks
                    if audiobooks.isEmpty {
                        Text("No local audiobooks found")
                            .font(.custom("RobotoCondensed-Bold", size: 16))
                            .foregroundColor(.textSecondary)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(audiobooks) { book in
                                AudiobookGridItem(book: book, isEditing: isEditing, onDelete: {
                                    viewModel.removeBook(book)
                                })
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Search Results
                    Text("Audiobook Search Results")
                        .font(.custom("RobotoCondensed-Bold", size: 22))
                        .foregroundColor(.textPrimary)
                        .padding()
                    
                    if searchViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentTeal))
                    } else if let errorMessage = searchViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.custom("RobotoCondensed-Bold", size: 16))
                            .foregroundColor(.red)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                ForEach(searchViewModel.searchResults, id: \.id) { result in
                                    VStack {
                                        AsyncImage(url: URL(string: result.coverImageURL ?? "")) { image in
                                            image.resizable()
                                                 .scaledToFit()
                                                 .frame(width: 120, height: 180)
                                                 .cornerRadius(10)
                                                 .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                        } placeholder: {
                                            Image(systemName: "book")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 120, height: 180)
                                                .foregroundColor(.textSecondary)
                                                .background(Color.cardBackground)
                                                .cornerRadius(10)
                                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                        }
                                        
                                        Text(result.title)
                                            .font(.custom("RobotoCondensed-Bold", size: 14))
                                            .foregroundColor(.textPrimary)
                                            .lineLimit(1)
                                        
                                        Text(result.author)
                                            .font(.custom("RobotoCondensed-Bold", size: 12))
                                            .foregroundColor(.textSecondary)
                                            .lineLimit(1)
                                        
                                        Button(action: {
                                            addAudiobookToLibrary(result)
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                                .imageScale(.large)
                                        }
                                        .padding(.top, 5)
                                    }
                                    .frame(width: 120)
                                    .padding(.horizontal, 5)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addAudiobookToLibrary(_ result: AudiobookSearchResult) {
        let newBook = Book(
            title: result.title,
            author: result.author,
            description: result.description,
            coverImage: nil,
            status: .audiobook,
            price: nil,
            audiobookDuration: nil,
            narrator: nil
        )
        
        if let coverUrlString = result.coverImageURL,
           let coverUrl = URL(string: coverUrlString) {
            URLSession.shared.dataTask(with: coverUrl) { [weak viewModel] data, _, _ in
                if let imageData = data {
                    DispatchQueue.main.async {
                        var bookWithImage = newBook
                        bookWithImage.coverImage = imageData
                        viewModel?.addBook(bookWithImage)
                    }
                }
            }.resume()
        } else {
            viewModel.addBook(newBook)
        }
    }
}








