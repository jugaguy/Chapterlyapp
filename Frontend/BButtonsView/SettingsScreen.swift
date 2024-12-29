//
//  SettingsScreen.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 12/12/2024.
//

import SwiftUI
import CoreData
import Foundation
import UserNotifications

struct SettingsScreen: View {
    @StateObject private var viewModel: BookViewModel
    @State private var showingConfirmationDialog = false
    @State private var confirmationDialogType: ConfirmationType?

    init(viewModel: BookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    enum ConfirmationType {
        case clearBooks
        case resetStats
        case clearNotes
    }

    private enum ButtonStyle {
        case destructive
        case review
    }

    var body: some View {
        ZStack {
            Color.softBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Destructive Action Buttons
                    Group {
                        settingsButton(
                            title: "Clear ALL Of Your Books",
                            style: .destructive
                        )

                        settingsButton(
                            title: "Reset Your Statistics",
                            style: .destructive
                        )

                        settingsButton(
                            title: "Clear ALL Notes",
                            style: .destructive
                        )
                    }

                    // Review Button
                    settingsButton(
                        title: "Leave a Review",
                        style: .review
                    )
                }
                .padding()
            }
            .confirmationDialog("Are you sure?", isPresented: $showingConfirmationDialog, titleVisibility: .visible) {
                Button("Confirm", role: .destructive) {
                    switch confirmationDialogType {
                    case .clearBooks:
                        clearAllBooks()
                    case .resetStats:
                        resetStatistics()
                    case .clearNotes:
                        clearAllNotes()
                    case .none:
                        break
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func settingsButton(
        title: String,
        style: ButtonStyle
    ) -> some View {
        Button(action: {
            switch style {
            case .destructive:
                confirmationDialogType = title.contains("Books") ? .clearBooks :
                                         title.contains("Statistics") ? .resetStats : .clearNotes
                showingConfirmationDialog = true
            case .review:
                if let url = URL(string: "https://apps.apple.com/app/yourappid") {
                    UIApplication.shared.open(url)
                }
            }
        }) {
            Text(title)
                .font(.custom("RobotoCondensed-Bold", size: 16))
                .foregroundColor(style == .destructive ? .red : .green)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style == .destructive ? Color.red.opacity(0.5) : Color.green.opacity(0.5), lineWidth: 1)
                )
        }
    }

    private func clearAllBooks() {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        
        do {
            let books = try viewModel.container.viewContext.fetch(fetchRequest)
            for book in books {
                viewModel.container.viewContext.delete(book)
            }
            
            try viewModel.container.viewContext.save()
            viewModel.loadBooks()
        } catch {
            print("Error clearing all books: \(error)")
        }
    }

    private func resetStatistics() {
        // This is a placeholder. Implement any specific statistic reset logic you need
        print("Resetting statistics")
    }

    private func clearAllNotes() {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        
        do {
            let books = try viewModel.container.viewContext.fetch(fetchRequest)
            for book in books {
                book.notes = nil
            }
            
            try viewModel.container.viewContext.save()
            viewModel.loadBooks()
        } catch {
            print("Error clearing all notes: \(error)")
        }
    }
}
