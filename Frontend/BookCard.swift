//
//  BookCard.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 16/11/2024.
//

import SwiftUI

struct BookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading) {
            if let imageData = book.coverImage,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 150)
            }
            
            Text(book.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(book.author)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(book.status.rawValue)
                .font(.caption)
                .foregroundColor(book.status.color)
            
            // Add price display
            if let price = book.price {
                Text("$\(String(format: "%.2f", price))")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .frame(width: 120)
    }
}

#Preview {
    BookDetailView(
        viewModel: BookViewModel(),
        book: Book(
            title: "Sample Book",
            author: "John Doe",
            description: "A great book",
            status: .library,
            price: 19.99  // Add price to the preview
        )
    )
}
