//
//  BookListItemView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

struct BookListItemView: View {
    let book: Book
    
    var body: some View {
        VStack {
            Text(book.title).font(.headline)
        }
    }
}
