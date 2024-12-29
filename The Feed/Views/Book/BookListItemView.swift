//
//  BookListItemView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

struct BookListItemView: View {
    let book: Book
    @ObservedObject private var assetViewModel: AssetViewModel
    
    init(withBook book: Book) {
        assetViewModel = AssetViewModel(book.coverImage)
        self.book = book
    }
    
    var body: some View {
        VStack {
            if let error = assetViewModel.error {
                Text("Error loading cover for \(book.title): \(error)")
            } else {
                HStack {
                    Text(book.title).font(.headline)
                }
            }
        }
        .onAppear {
            assetViewModel.fetchData()
        }
    }
}
