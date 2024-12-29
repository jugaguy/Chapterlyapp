//
//  CompletedSection.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 19/11/2024.
//

import SwiftUI

struct CompletedSection: View {
    let title: String = "Completed"
    @State private var books: [Book]
    @ObservedObject var viewModel: BookViewModel
    
    init(viewModel: BookViewModel) {
        self._books = State(initialValue: viewModel.books.filter { $0.status == .read })
        self.viewModel = viewModel
    }
    
    var body: some View {
        BookSection(
            title: title,
            books: viewModel.books.filter { $0.status == .read },
            viewModel: viewModel
        )
    }
}

#Preview {
    NavigationStack {
        CompletedSection(viewModel: BookViewModel())
            .background(Color.black)
    }
}

