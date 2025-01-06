//
//  EntryCardView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/31/24.
//

import SwiftUI

/**
 Shows the detail view for each item
 */
struct EntryCardView: View {
    @EnvironmentObject var viewModel: EntriesViewModel
    @Binding var entry: Entry
    
    /**
     Current highlight state for this item
     */
    private var state: ItemHighlightState { viewModel.states[entry.id]! }
    
    var body: some View {
        Group {
            switch entry {
            case .book(let book):
                BookCardView(book: book)
            case .location(let location):
                LocationCardView(location: location)
            case .textBlock(let textBlock):
                TextBlockCardView(textBlock: textBlock)
            }
        }
    }
}

