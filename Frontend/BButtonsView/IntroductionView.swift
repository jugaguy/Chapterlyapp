//
//  IntroductionView.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 15/12/2024.
//

import SwiftUI

struct IntroductionView: View {
    @State private var currentPage = 0
    @AppStorage("hasCompletedIntro") private var hasCompletedIntro = false
    
    
    let introPages: [IntroPage] = [
        
            IntroPage(
                title: "Welcome to Chapterly",
                description: "Discover a new way to manage and enjoy your reading journey. Chapterly helps you track, organize, and celebrate your reading experiences.",
                imageName: "ChapBook", // Your custom image name
                accentColor: .black.opacity(0.8),
                isCustomImage: true // Specify that this is a custom image
            ),
            IntroPage(
                title: "Track Your Reading",
                description: "Monitor your reading progress with intuitive graphs, detailed statistics, and personalized insights. Understand your reading habits like never before.",
                imageName: "ChapStats",
                accentColor: .black.opacity(0.8),
                isCustomImage: true
            ),
            IntroPage(
                title: "Organize Your Library",
                description: "Easily add books, create wishlists, and keep track of your reading goals. Your personal library is just a tap away.",
                imageName: "ChapLibrary",
                accentColor: .black.opacity(0.8),
                isCustomImage: true
            ),
            IntroPage(
                title: "Journal Your Thoughts",
                description: "Capture your reading journey with personal journal entries. Save memorable quotes, reflections, and insights directly within each book.",
                imageName: "NotesChap",
                accentColor: .black.opacity(0.8),
                isCustomImage: true
            ),
            IntroPage(
                title: "Scan and Add Books",
                description: "Easily add books to your library by scanning their barcode. No more manual entry - just scan and start tracking your reading instantly!",
                imageName: "ChapScanner",
                accentColor: .black.opacity(0.8),
                isCustomImage: true
            )
        ]

    
    var body: some View {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Section with Logo and App Name
                    HStack(spacing: -10) {  // Add spacing parameter
                        Image("Chapterlylogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                        
                        Text("Chapterly")
                            .font(.custom("RobotoCondensed-Bold", size: 30))
                            .foregroundColor(.black)
                            .offset(y: 10)  // Move the text down by 5 points
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Current Page Content
                    introPages[currentPage]
                    
                    Spacer()
                    
                    // Navigation Button
                    Button(action: {
                        withAnimation {
                            if currentPage < introPages.count - 1 {
                                currentPage += 1
                            } else {
                                hasCompletedIntro = true
                            }
                        }
                    }) {
                        Text(currentPage == introPages.count - 1 ? "Get Started" : "Next")
                            .font(.custom("RobotoCondensed-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    // Page Indicator
                    HStack {
                        ForEach(0..<introPages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.black : Color.gray)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
    }

struct IntroPage: View {
    let title: String
    let description: String
    let imageName: String
    let accentColor: Color
    let isCustomImage: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Conditional image rendering
            if isCustomImage {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            } else {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(accentColor)
            }
            
            Text(title)
                .font(.custom("RobotoCondensed-Bold", size: 24))
                .foregroundColor(.black)
            
            Text(description)
                .font(.custom("RobotoCondensed-Regular", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .padding()
    }
}

