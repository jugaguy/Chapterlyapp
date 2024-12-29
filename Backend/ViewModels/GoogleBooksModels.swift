//
//  GoogleBooksModels.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 08/12/2024.
//

import Foundation

struct GoogleBooksAPIResponse: Codable {
    let kind: String?
    let totalItems: Int?
    let items: [GoogleBookItem]?
}

struct GoogleBookItem: Codable, Identifiable {
    let id: String
    let volumeInfo: GoogleBookVolumeInfo
    let saleInfo: GoogleBookSaleInfo?
    let accessInfo: GoogleBookAccessInfo?
}

struct GoogleBookVolumeInfo: Codable {
    let title: String
    let subtitle: String?
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
    let categories: [String]?
    let averageRating: Double?
    let ratingsCount: Int?
    let imageLinks: GoogleBookImageLinks?
    let language: String?
    let previewLink: String?
    let infoLink: String?
}

struct GoogleBookImageLinks: Codable {
    let smallThumbnail: String?
    let thumbnail: String?
    let small: String?
    let medium: String?
    let large: String?
    let extraLarge: String?
}

struct GoogleBookSaleInfo: Codable {
    let country: String?
    let saleability: String?
    let isEbook: Bool?
    let listPrice: GoogleBookPrice?
    let retailPrice: GoogleBookPrice?
    let buyLink: String?
}

struct GoogleBookPrice: Codable {
    let amount: Double?
    let currencyCode: String?
}

struct GoogleBookAccessInfo: Codable {
    let country: String?
    let viewability: String?
    let embeddable: Bool?
    let publicDomain: Bool?
    let textToSpeechPermission: String?
    let epub: GoogleBookFormat?
    let pdf: GoogleBookFormat?
    let webReaderLink: String?
    let accessViewStatus: String?
    let quotingDisabled: Bool?
}

struct GoogleBookFormat: Codable {
    let isAvailable: Bool?
    let acsTokenLink: String?
}



