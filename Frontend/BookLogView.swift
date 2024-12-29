//
//  BookLogView.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 20/12/2024.
//

import SwiftUI
import CoreData


struct BookLogView: View {
    let book: Book
    @StateObject private var bookViewModel: BookViewModel
    @State private var bookSessions: [ReadingSession] = []
    
    init(book: Book, bookViewModel: BookViewModel) {
        self.book = book
        self._bookViewModel = StateObject(wrappedValue: bookViewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Book Details Card
                bookDetailsCard
                
                // Reading Sessions List
                readingSessionsList
            }
            .padding()
            .navigationTitle("Your Book Log")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                
                fetchBookSessions()
            }
        }
        .background(Color.softBackground)
    }
    
    private var bookDetailsCard: some View {
        HStack {
            // Book Cover
            if let imageData = book.coverImage, let uiImage = UIImage(data: imageData) {
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
                Text(book.title)
                    .font(.custom("RobotoCondensed-Bold", size: 20))
                    .foregroundColor(.textPrimary)
                
                Text(book.author)
                    .font(.custom("RobotoCondensed-Regular", size: 16))
                    .foregroundColor(.textSecondary)
                
                Text("Total Reading Time")
                    .font(.custom("RobotoCondensed-Bold", size: 14))
                    .foregroundColor(.textSecondary)
                
                Text(formatReadingTime(book.totalReadingTime))
                    .font(.custom("RobotoCondensed-Bold", size: 24))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var readingSessionsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reading Sessions")
                .font(.custom("RobotoCondensed-Bold", size: 18))
                .foregroundColor(.textSecondary)
            
            if bookSessions.isEmpty {
                Text("No reading sessions yet")
                    .font(.custom("RobotoCondensed-Regular", size: 16))
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(bookSessions) { session in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(session.date, style: .date)
                                    .font(.custom("RobotoCondensed-Bold", size: 16))
                                    .foregroundColor(.textPrimary)
                                
                                Text(session.date, style: .time)
                                    .font(.custom("RobotoCondensed-Regular", size: 14))
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                            
                            Text(formatReadingTime(session.duration))
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
        }
    }
    
    private func fetchBookSessions() {
        bookSessions = bookViewModel.getReadingSessions(for: book)
    }
    
    private func formatReadingTime(_ time: Double) -> String {
        let hours = Int(time)
        let minutes = Int((time - Double(hours)) * 60)
        return "\(hours) hrs \(minutes) mins"
    }
}
