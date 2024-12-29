//
//  ToBeReadSection.swift
//  ChapterlyV2
//
//  Created by arslaan ahmed on 19/11/2024.
//

import SwiftUI

struct ToBeReadSection: View {
    let title: String = "To Be Read"
    @State private var books: [Book]
    @ObservedObject var viewModel: BookViewModel
    
    init(viewModel: BookViewModel) {
        self._books = State(initialValue: viewModel.books.filter { $0.status == .toBeRead })
        self.viewModel = viewModel
    }
    
    var body: some View {
        BookSection(
            title: title,
            books: viewModel.books.filter { $0.status == .toBeRead },
            viewModel: viewModel
        )
    }
}

#Preview {
    NavigationStack {
        ToBeReadSection(viewModel: BookViewModel())
            .background(Color.black)
    }
}

