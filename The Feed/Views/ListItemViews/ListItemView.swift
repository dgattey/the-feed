//
//  ListItemView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

/**
 Shows a preview of each item in a list view - this delegates out to all the other views.
 */
struct ListItemView: View {
    let entry: Entry
    
    var body: some View {
        NavigationLink(destination: destinationView(for: entry)) {
            switch entry {
            case .book(let book):
                BookListItemView(book: book)
            case .location(let location):
                LocationListItemView(location: location)
            case .unknown:
                VStack {
                    Text("Unknown").font(.headline)
                }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for entry: Entry) -> some View {
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
