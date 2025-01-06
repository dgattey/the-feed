//
//  BookCardView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/31/24.
//

import SwiftUI

fileprivate struct Constants {
#if os(macOS)
    static let nonImageGridCellColumns = 4
#else
    static let nonImageGridCellColumns = 5
#endif
}

/**
 Shows a single book item for a list item view
 */
struct BookCardView: View {
    let book: Book
    @EnvironmentObject private var errorsViewModel: ErrorsViewModel
    @EnvironmentObject private var viewModel: EntriesViewModel
    
    private var state: ItemHighlightState { viewModel.states[book.id]! }
    
    var body: some View {
        Grid(horizontalSpacing: 18.0) {
            GridRow {
                CoverImageView(
                    with: book,
                    errorsViewModel
                )
                
                Grid(alignment: .leadingFirstTextBaseline, verticalSpacing: 4) {
                    GridRow {
                        Text(book.title).font(.headline)
                    }
                    GridRow {
                        Text(book.author).font(.subheadline)
                    }
                    GridRow {
                        if let readDateFinished = book.readDateFinished {
                            Text("Finished on \(readDateFinished.formatted(date: .abbreviated, time: .omitted))")
                        } else if let readDateStarted = book.readDateStarted {
                            Text("Started reading on \(readDateStarted.formatted(date: .abbreviated, time: .omitted))")
                        } else if let createdAt = book.sysContent.createdAt {
                            Text("Created on \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                        }
                    }
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .gridCellColumns(Constants.nonImageGridCellColumns)
            }
        }
        .padding()
        .background(CardView(hasClearBackground: false, state))
    }
}
