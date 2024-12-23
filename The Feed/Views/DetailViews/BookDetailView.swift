//
//  BookDetailView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book
    
    var body: some View {
        Text("Details for \(book.title)")
            .font(.largeTitle)
            .padding()
    }
}
