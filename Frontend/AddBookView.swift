//
//  AddBookView.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 16/11/2024.
//

import SwiftUI

struct AddBookView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: BookViewModel
    @State private var title = ""
    @State private var author = ""
    @State private var description = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Book Details") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(4)
                }
                
                Section("Cover Image") {
                    Button {
                        showingImagePicker = true
                    } label: {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Add New Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveBook()
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    private func saveBook() {
        let newBook = Book(
            title: title,
            author: author,
            description: description,
            coverImage: selectedImage?.jpegData(compressionQuality: 0.8),
            status: .wishlist,
            price: nil  // Or you can add a price text field if you want to specify
        )
        viewModel.addBook(newBook)
        dismiss()
    }
}
