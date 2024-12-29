//
//  BookNotesView.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 16/11/2024.
//

import SwiftUI

struct BookNotesView: View {
    let book: Book
    @ObservedObject var viewModel: BookViewModel
    
    @State private var newNote: String = ""
    @State private var isAddingNote = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.softBackground.ignoresSafeArea()
                
                VStack {
                    // Book Header
                    bookHeaderSection
                    
                    // Notes List
                    if bookNotes.isEmpty {
                        emptyNotesView
                    } else {
                        notesListSection
                    }
                }
            }
            .navigationTitle("Book Journals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingNote = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $isAddingNote) {
                addNoteSheet
            }
        }
    }
    
    private var bookHeaderSection: some View {
        HStack {
            if let imageData = book.coverImage, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 150)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            } else {
                Image(systemName: "book.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 150)
                    .foregroundColor(.textSecondary)
                    .background(Color.cardBackground)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding()
    }
    
    private var emptyNotesView: some View {
        VStack {
            Text("No journal entries yet")
                .foregroundColor(.textSecondary)
            
            Button(action: { isAddingNote = true }) {
                Text("Add First Entry")
                    .foregroundColor(.accentTeal)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        .padding()
    }
    
    private var notesListSection: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(bookNotes.indices, id: \.self) { index in
                    noteRowView(bookNotes[index])
                }
            }
            .padding()
        }
    }
    
    private func noteRowView(_ note: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(note)
                    .foregroundColor(.textPrimary)
                
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var addNoteSheet: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $newNote)
                    .frame(minHeight: 200)
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
            .navigationTitle("New Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isAddingNote = false
                        newNote = ""
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNewNote()
                    }
                    .disabled(newNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var bookNotes: [String] {
        book.notes?.components(separatedBy: .newlines).filter { !$0.isEmpty } ?? []
    }
    
    private func saveNewNote() {
        let trimmedNote = newNote.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNote.isEmpty else { return }
        
        let updatedNotes = (bookNotes + [trimmedNote]).joined(separator: "\n")
        viewModel.updateBookNotes(book, notes: updatedNotes)
        
        newNote = ""
        isAddingNote = false
    }
}


