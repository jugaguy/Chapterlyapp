//
//  BookDetailView.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 16/11/2024.
//

import SwiftUI

struct BookDetailView: View {
    @ObservedObject var viewModel: BookViewModel
    let book: Book
    
    @State private var showingStatusSheet = false
    @State private var showingNotes = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Book Cover
                if let imageData = book.coverImage, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(book.title)
                        .font(.custom("RobotoCondensed-Bold", size: 24))
                        .foregroundColor(.textPrimary)
                    
                    Text(book.author)
                        .font(.custom("RobotoCondensed-Bold", size: 20))
                        .foregroundColor(.textSecondary)
                    
                    Text(book.status.rawValue)
                        .font(.custom("RobotoCondensed-Bold", size: 14))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(book.status.color.opacity(0.2))
                        .foregroundColor(book.status.color)
                        .clipShape(Capsule())
                    
                    Text(book.description)
                        .font(.custom("RobotoCondensed-Bold", size: 16))
                        .foregroundColor(.textPrimary)
                        .padding(.top)
                    
                    // Conditionally show price only for Wishlist
                    if book.status == .wishlist, let price = book.price {
                        Text("Price: $\(String(format: "%.2f", price))")
                            .font(.custom("RobotoCondensed-Bold", size: 16))
                            .foregroundColor(.green)
                            .padding(5)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(5)
                    }
                }
                .padding()
                
                VStack(spacing: 15) {
                    detailButton(
                        title: "Change Status",
                        systemImage: "arrow.triangle.2.circlepath",
                        action: { showingStatusSheet = true }
                    )
                    
                    detailButton(
                        title: "Add journal entries",
                        systemImage: "note.text",
                        action: { showingNotes = true }
                    )
                    
                    detailButton(
                        title: "Add to Wishlist",
                        systemImage: "cart",
                        action: { viewModel.updateBookStatus(book, status: .wishlist) }
                    )
                }
                .padding()
            }
        }
        .background(Color.softBackground)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Change Book Status", isPresented: $showingStatusSheet) {
            Button("To Be Read") { updateStatus(.toBeRead) }
            Button("Read") { updateStatus(.read) }
            Button("Wishlist") { updateStatus(.wishlist) }
            Button("Library") { updateStatus(.library) }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingNotes) {
            BookNotesView(book: book, viewModel: viewModel)
        }
    }
    
    private func detailButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.custom("RobotoCondensed-Bold", size: 16))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private func updateStatus(_ status: BookStatus) {
        viewModel.updateBookStatus(book, status: status)
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
            price: 0
        )
    )
}

