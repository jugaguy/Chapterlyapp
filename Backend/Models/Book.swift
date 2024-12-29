//
//  Book.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 16/11/2024.
//

import SwiftUI
import Foundation

enum BookStatus: String, Codable, CaseIterable {
    case library = "Library"
    case toBeRead = "To Be Read"
    case read = "Completed"
    case wishlist = "Wishlist"
    case audiobook = "Audiobook"
    
    var color: Color {
        switch self {
        case .library: return .blue
        case .toBeRead: return .orange
        case .read: return .green
        case .wishlist: return .purple
        case .audiobook: return .purple.opacity(0.7)
        }
    }
}

enum BookGenre: String, Codable, CaseIterable {
    case fantasy = "Fantasy"
    case scienceFiction = "Science Fiction"
    case mystery = "Mystery"
    case romance = "Romance"
    case historicalFiction = "Historical Fiction"
    case nonFiction = "Non-Fiction"
    case thriller = "Thriller"
    case youngAdult = "Young Adult"
}

enum BookMood: String, Codable, CaseIterable {
    case inspirational = "Inspirational"
    case adventurous = "Adventurous"
    case relaxing = "Relaxing"
    case thoughtProvoking = "Thought-Provoking"
    case emotional = "Emotional"
    case humorous = "Humorous"
}

struct Book: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var author: String
    var description: String
    var coverImage: Data?
    var status: BookStatus
    var dateAdded: Date
    var rating: Int?
    var notes: String?
    var price: Double?
    var totalReadingTime: Double = 0.0
    
    // Enhanced book metadata
    var genre: BookGenre?
    var mood: BookMood?
    var pageCount: Int?
    var publishDate: String?
    var categories: String?
    
    // Audiobook-specific properties
    var audiobookDuration: TimeInterval?
    var narrator: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        description: String,
        coverImage: Data? = nil,
        status: BookStatus = .library,
        dateAdded: Date = Date(),
        rating: Int? = nil,
        notes: String? = nil,
        price: Double? = nil,
        genre: BookGenre? = nil,
        mood: BookMood? = nil,
        pageCount: Int? = nil,
        publishDate: String? = nil,
        categories: String? = nil,
        audiobookDuration: TimeInterval? = nil,
        narrator: String? = nil,
        totalReadingTime: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.coverImage = coverImage
        self.status = status
        self.dateAdded = dateAdded
        self.rating = rating
        self.notes = notes
        self.price = price
        self.genre = genre
        self.mood = mood
        self.pageCount = pageCount
        self.publishDate = publishDate
        self.categories = categories
        self.audiobookDuration = audiobookDuration
        self.narrator = narrator
        self.totalReadingTime = totalReadingTime
    }
    
    var isAudiobook: Bool {
        return status == .audiobook
    }
    
    var formattedDuration: String? {
        guard let duration = audiobookDuration else { return nil }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return hours > 0 ? "\(hours) hr \(minutes) min" : "\(minutes) min"
    }
    
    // Convenience method to infer genre from categories
    mutating func inferGenre() {
        guard let categories = categories else { return }
        
        let lowercasedCategories = categories.lowercased()
        
        if lowercasedCategories.contains("fantasy") {
            self.genre = .fantasy
        } else if lowercasedCategories.contains("science fiction") {
            self.genre = .scienceFiction
        } else if lowercasedCategories.contains("mystery") {
            self.genre = .mystery
        } else if lowercasedCategories.contains("romance") {
            self.genre = .romance
        } else if lowercasedCategories.contains("historical") {
            self.genre = .historicalFiction
        } else if lowercasedCategories.contains("non-fiction") {
            self.genre = .nonFiction
        } else if lowercasedCategories.contains("thriller") {
            self.genre = .thriller
        } else if lowercasedCategories.contains("young adult") {
            self.genre = .youngAdult
        }
    }
}

