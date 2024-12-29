//
//  EntriesListSectionView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

/**
 Shows a section in the list view for entries - shows a group name and entries below.
 */
struct EntriesListSectionView: View {
    @Binding var group: GroupedEntries
    
    var body: some View {
        Section(header: Text(group.id)) {
            ForEach($group.entries) { $entry in
                EntriesListItemView(entry: $entry)
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        #if os(iOS)
        .listSectionSpacing(.custom(24))
        #endif
    }
}

/**
 Shows an individual entry in the list of all entries, to be clicked on.
 */
private struct EntriesListItemView: View {
    @Binding var entry: Entry
    
    var body: some View {
        NavigationLink(value: entry) {
            switch entry {
            case .book(let book):
                BookListItemView(withBook: book)
            case .location(let location):
                LocationListItemView(location: location)
            case .textBlock(let textBlock):
                TextBlockListItemView(textBlock: textBlock)
            }
        }
        .listRowBackground(Color.clear)
    }
}
