//
//  DetailView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

/**
 Shows the detail view for each item
 */
struct DetailView: View {
    let entry: Entry
    
    var body: some View {
        switch entry {
        case .book(let book):
            BookDetailView(book: book)
        case .location(let location):
            LocationDetailView(location: location)
        case .unknown:
            Text("Unknown")
        }
    }
}
