//
//  ReadingTimerView.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 19/12/2024.
//

import SwiftUI
import UIKit

struct ReadingTimerView: View {
    let book: Book
    @ObservedObject var viewModel: BookViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showBookLog = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Library")
                .font(.custom("RobotoCondensed-Bold", size: 22))
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.books.filter { $0.status == .library }) { book in
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
                                        
                                        if let price = book.price {
                                            Text("$\(String(format: "%.2f", price))")
                                                .font(.custom("RobotoCondensed-Bold", size: 14))
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    // Track the book
                                    viewModel.trackBook(book)
                                }) {
                                    Text("Track")
                                        .font(.custom("RobotoCondensed-Bold", size: 14))
                                        .foregroundColor(.textPrimary)
                                        .frame(width: 100, height: 30)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                                
                                NavigationLink(destination: BookLogView(book: book, bookViewModel: viewModel)) {
                                    Text("Book Log")
                                        .font(.custom("RobotoCondensed-Bold", size: 14))
                                        .foregroundColor(.textPrimary)
                                        .frame(width: 100, height: 30)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
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
                                    .sheet(isPresented: $showBookLog) {
                                        Text("Book Log")
                                    }
                                }
                            }
