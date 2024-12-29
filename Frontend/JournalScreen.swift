//
//  JournalScreen.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 10/12/2024.
//

import SwiftUI

struct JournalScreen: View {
    @StateObject private var viewModel = BookViewModel()
    @State private var selectedBook: Book?
    
    var libraryBooks: [Book] {
        viewModel.books.filter { $0.status == .library }
    }
    
    var booksWithNotes: [Book] {
        viewModel.books.filter { $0.notes?.isEmpty == false }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.softBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Library Books Section
                        libraryBooksSection
                        
                        // View Journals Section
                        viewJournalsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Journals")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleFont(.custom("RobotoCondensed-Bold", size: 22))
        }
    }
    
    private var libraryBooksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Library Books")
                .font(.custom("RobotoCondensed-Bold", size: 20))
                .foregroundColor(.textPrimary)
            
            if libraryBooks.isEmpty {
                Text("No books in library")
                    .font(.custom("RobotoCondensed-Bold", size: 16))
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(libraryBooks) { book in
                            NavigationLink(destination: BookNotesView(book: book, viewModel: viewModel)) {
                                VStack {
                                    if let imageData = book.coverImage, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 120, height: 180)
                                            .cornerRadius(10)
                                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    } else {
                                        Image(systemName: "book.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 120, height: 180)
                                            .foregroundColor(.textSecondary)
                                            .background(Color.cardBackground)
                                            .cornerRadius(10)
                                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                    
                                    Text(book.title)
                                        .font(.custom("RobotoCondensed-Bold", size: 14))
                                        .foregroundColor(.textPrimary)
                                        .lineLimit(1)
                                    
                                    Text(book.author)
                                        .font(.custom("RobotoCondensed-Bold", size: 12))
                                        .foregroundColor(.textSecondary)
                                        .lineLimit(1)
                                }
                                .frame(width: 120)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var viewJournalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("View Journals")
                .font(.custom("RobotoCondensed-Bold", size: 20))
                .foregroundColor(.textPrimary)
            
            if booksWithNotes.isEmpty {
                Text("No journal entries")
                    .font(.custom("RobotoCondensed-Bold", size: 16))
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 10) {
                    ForEach(booksWithNotes) { book in
                        NavigationLink(destination: BookNotesView(book: book, viewModel: viewModel)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(book.title)
                                        .font(.custom("RobotoCondensed-Bold", size: 18))
                                        .foregroundColor(.textPrimary)
                                    
                                    Text(book.notes?.components(separatedBy: .newlines).first ?? "")
                                        .font(.custom("RobotoCondensed-Bold", size: 16))
                                        .foregroundColor(.textSecondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.textSecondary)
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    JournalScreen()
}

// Extension to add navigationBarTitleFont modifier
extension View {
    func navigationBarTitleFont(_ font: Font) -> some View {
        self.modifier(NavigationBarTitleFontModifier(font: font))
    }
}

struct NavigationBarTitleFontModifier: ViewModifier {
    let font: Font
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(verbatim: "Journals")
                        .font(font)
                        .foregroundColor(.textPrimary)
                }
            }
    }
}

