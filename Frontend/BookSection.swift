//
//  BookSection.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 16/11/2024.
//

import SwiftUI
import CoreData

struct BookSection: View {
    let title: String
    @State private var books: [Book]
    @ObservedObject var viewModel: BookViewModel
    
    init(title: String, books: [Book], viewModel: BookViewModel) {
        self.title = title
        self._books = State(initialValue: books)
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.custom("RobotoCondensed-Bold", size: 22))
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.books.filter { book in
                        switch title {
                        case "All Books":
                            return true
                        case "Library":
                            return book.status == .library
                        case "To Be Read":
                            return book.status == .toBeRead
                        case "Completed":
                            return book.status == .read
                        case "Wishlist":
                            return book.status == .wishlist
                        default:
                            return false
                        }
                    }) { book in
                        VStack {
                            NavigationLink(destination: BookDetailView(viewModel: viewModel, book: book)) {
                                HStack(spacing: 15) {
                                    if let imageData = book.coverImage,
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 120)
                                            .cornerRadius(8)
                                            .clipped()
                                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    } else {
                                        Image(systemName: "book.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 120)
                                            .background(Color.cardBackground)
                                            .cornerRadius(8)
                                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(book.title)
                                            .font(.custom("RobotoCondensed-Bold", size: 18))
                                            .foregroundColor(.textPrimary)
                                        
                                        Text(book.author)
                                            .font(.custom("RobotoCondensed-Bold", size: 16))
                                            .foregroundColor(.textSecondary)
                                        
                                        Text(book.description)
                                            .font(.custom("RobotoCondensed-Bold", size: 14))
                                            .foregroundColor(.textSecondary)
                                            .lineLimit(2)
                                        
                                        // Add price display
                                        if let price = book.price {
                                            Text("$\(String(format: "%.2f", price))")
                                                .font(.custom("RobotoCondensed-Bold", size: 14))
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            
                            // Action Buttons
                            HStack(spacing: 20) {
                                actionButton(color: .orange, icon: Text("..."), action: { moveBook(book, to: .toBeRead) })
                                actionButton(color: .green, icon: Image(systemName: "checkmark"), action: { moveBook(book, to: .read) })
                                actionButton(color: .blue, icon: Image(systemName: "book.fill"), action: { moveBook(book, to: .library) })
                                actionButton(color: .purple, icon: Image(systemName: "cart"), action: { moveBook(book, to: .wishlist) })
                                actionButton(color: .red, icon: Image(systemName: "trash.fill"), action: { deleteBook(book) })
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.softBackground.ignoresSafeArea())
    }
    
    private func actionButton(color: Color, icon: some View, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
                
                icon
                    .foregroundColor(.white)
                    .font(.custom("RobotoCondensed-Bold", size: 16))
            }
        }
    }
    
    private func moveBook(_ book: Book, to status: BookStatus) {
        viewModel.updateBookStatus(book, status: status)
    }
    
    private func deleteBook(_ book: Book) {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", book.id as CVarArg)
        
        do {
            let results = try viewModel.container.viewContext.fetch(fetchRequest)
            if let bookEntity = results.first {
                viewModel.container.viewContext.delete(bookEntity)
                try viewModel.container.viewContext.save()
                
                viewModel.loadBooks()
            }
        } catch {
            print("Error deleting book: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        BookSection(
            title: "Sample Books",
            books: [
                Book(
                    title: "The Great Gatsby",
                    author: "F. Scott Fitzgerald",
                    description: "A novel about the decadence and excess of the Jazz Age.",
                    status: .library,
                    price: 12.99
                ),
                Book(
                    title: "1984",
                    author: "George Orwell",
                    description: "A dystopian social science fiction novel and cautionary tale.",
                    status: .toBeRead,
                    price: 10.50
                ),
                Book(
                    title: "Pride and Prejudice",
                    author: "Jane Austen",
                    description: "A romantic novel of manners set in early 19th-century England.",
                    status: .read,
                    price: 8.75
                )
            ],
            viewModel: BookViewModel()
        )
    }
}







