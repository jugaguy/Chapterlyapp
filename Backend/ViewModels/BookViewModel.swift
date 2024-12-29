//
//  BookViewModel.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 16/11/2024.
//

import SwiftUI
import CoreData
import Foundation
import WidgetKit

class BookViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var selectedBook: Book?
    @Published var showingAddBook = false
    @Published var showingScanner = false
    @Published var currentlyReadingBook: Book?
    
    // Make container public
    public let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "BookLibrary")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error)")
            }
        }
        loadBooks()
    }
    
    func trackBook(_ book: Book) {
        currentlyReadingBook = book
        updateWidgetData(book)
        updateBookStatus(book, status: .library)
    }
    
    func getMostReadBook() -> Book? {
        if let currentBook = currentlyReadingBook {
            return currentBook
        }
        
        return books.max(by: { $0.totalReadingTime < $1.totalReadingTime })
    }
    
    func addBook(_ book: Book) {
        let newBook = BookEntity(context: container.viewContext)
        newBook.id = book.id
        newBook.title = book.title
        newBook.author = book.author
        newBook.bookDescription = book.description
        newBook.coverImage = book.coverImage
        newBook.status = book.status.rawValue
        newBook.dateAdded = book.dateAdded
        newBook.genre = book.genre?.rawValue
        newBook.mood = book.mood?.rawValue
        newBook.price = book.price ?? 0.0
        newBook.totalReadingTime = book.totalReadingTime
        
        do {
            try container.viewContext.save()
            print("Book saved successfully with price: \(newBook.price)")
            loadBooks()
            updateWidgetData(book)
        } catch {
            print("Error saving book: \(error)")
        }
    }
    
    func loadBooks() {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        
        do {
            let fetchedBooks = try container.viewContext.fetch(fetchRequest)
            
            books = fetchedBooks.map { bookEntity in
                Book(
                    id: bookEntity.id ?? UUID(),
                    title: bookEntity.title ?? "",
                    author: bookEntity.author ?? "",
                    description: bookEntity.bookDescription ?? "",
                    coverImage: bookEntity.coverImage,
                    status: BookStatus(rawValue: bookEntity.status ?? "") ?? .library,
                    dateAdded: bookEntity.dateAdded ?? Date(),
                    rating: Int(bookEntity.rating),
                    notes: bookEntity.notes,
                    price: bookEntity.price > 0 ? bookEntity.price : nil,
                    genre: BookGenre(rawValue: bookEntity.genre ?? ""),
                    mood: BookMood(rawValue: bookEntity.mood ?? ""),
                    totalReadingTime: bookEntity.totalReadingTime
                )
            }
        } catch {
            print("Error fetching books: \(error)")
        }
    }
    
    func updateBook(_ book: Book) {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", book.id as CVarArg)
        
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            if let bookEntity = results.first {
                bookEntity.title = book.title
                bookEntity.author = book.author
                bookEntity.bookDescription = book.description
                bookEntity.coverImage = book.coverImage
                bookEntity.status = book.status.rawValue
                bookEntity.genre = book.genre?.rawValue
                bookEntity.mood = book.mood?.rawValue
                bookEntity.price = book.price ?? 0.0
                
                try container.viewContext.save()
                loadBooks()
                updateWidgetData(book)
            }
        } catch {
            print("Error updating book: \(error)")
        }
    }
    
    func updateBookStatus(_ book: Book, status: BookStatus) {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", book.id as CVarArg)
        
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            if let bookEntity = results.first {
                bookEntity.status = status.rawValue
                
                if bookEntity.coverImage == nil {
                    bookEntity.coverImage = book.coverImage
                }
                
                try container.viewContext.save()
                loadBooks()
                updateWidgetData(book)
            }
        } catch {
            print("Error updating book status: \(error)")
        }
    }
    
    func updateBookNotes(_ book: Book, notes: String) {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", book.id as CVarArg)
        
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            if let bookEntity = results.first {
                bookEntity.notes = notes
                
                try container.viewContext.save()
                loadBooks()
            }
        } catch {
            print("Error updating book notes: \(error)")
        }
    }
    
    func updateBookReadingTime(_ book: Book, time: Double) {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", book.id as CVarArg)
        
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            if let bookEntity = results.first {
                bookEntity.totalReadingTime += time
                
                saveReadingSession(for: book, duration: time)
                
                try container.viewContext.save()
                loadBooks()
                updateWidgetData(book)
            }
        } catch {
            print("Error updating book reading time: \(error)")
        }
    }
    
    func removeBook(_ book: Book) {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", book.id as CVarArg)
        
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            if let bookEntity = results.first {
                container.viewContext.delete(bookEntity)
                try container.viewContext.save()
                loadBooks()
                refreshWidgetData()
            }
        } catch {
            print("Error removing book: \(error)")
        }
    }
    
    func saveContext() {
        do {
            try container.viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func getReadingSessions(for book: Book) -> [ReadingSession] {
        let fetchRequest: NSFetchRequest<ReadingSessionEntity> = ReadingSessionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "bookId == %@", book.id.uuidString)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let sessions = try container.viewContext.fetch(fetchRequest)
            return sessions.compactMap { session in
                guard let id = session.id,
                      let bookId = session.bookId,
                      let date = session.date else {
                    return nil
                }
                
                return ReadingSession(
                    id: id,
                    bookId: UUID(uuidString: bookId)!,
                    date: date,
                    duration: session.duration
                )
            }
        } catch {
            print("Error fetching reading sessions: \(error)")
            return []
        }
    }
    
    func saveReadingSession(for book: Book, duration: Double) {
        let newSession = ReadingSessionEntity(context: container.viewContext)
        newSession.id = UUID()
        newSession.bookId = book.id.uuidString
        newSession.date = Date()
        newSession.duration = duration
        
        do {
            try container.viewContext.save()
            print("Reading session saved successfully")
        } catch {
            print("Error saving reading session: \(error)")
        }
    }
    
    // New method to update widget data
    private func updateWidgetData(_ book: Book) {
        let defaults = UserDefaults(suiteName: "group.com.juga.chapterlyV2")!
        
        defaults.set(book.title, forKey: "mostReadBookTitle")
        defaults.set(book.author, forKey: "mostReadBookAuthor")
        defaults.set(book.totalReadingTime, forKey: "mostReadBookTotalTime")
        
        if let coverImage = book.coverImage {
            defaults.set(coverImage, forKey: "mostReadBookCoverImage")
        }
        
        WidgetCenter.shared.reloadTimelines(ofKind: "ReadingTimerWidget")
    }
    
    // Method to manually refresh widget data
    func refreshWidgetData() {
        if let mostReadBook = getMostReadBook() {
            updateWidgetData(mostReadBook)
        }
    }
}

// Existing ReadingSession struct
struct ReadingSession: Identifiable {
    let id: UUID
    let bookId: UUID
    let date: Date
    let duration: Double
}
