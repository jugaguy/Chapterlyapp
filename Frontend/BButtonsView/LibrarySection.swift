//
//  LibrarysECTION.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 19/11/2024.
//

import SwiftUI

struct LibrarySection: View {
    let title: String = "Library"
    @State private var books: [Book]
    @ObservedObject var viewModel: BookViewModel
    
    init(viewModel: BookViewModel) {
        self._books = State(initialValue: viewModel.books.filter { $0.status == .library })
        self.viewModel = viewModel
    }
    
    var body: some View {
        BookSection(
            title: title,
            books: viewModel.books.filter { $0.status == .library },
            viewModel: viewModel
        )
    }
}

#Preview {
    NavigationStack {
        LibrarySection(viewModel: BookViewModel())
            .background(Color.black)
    }
}
