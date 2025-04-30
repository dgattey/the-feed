//
//  BookListItemView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
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
struct BookListItemView: View {
    let book: Book
    @EnvironmentObject private var errorsViewModel: ErrorsViewModel
    @EnvironmentObject private var currentSurface: CurrentSurface
    @EnvironmentObject private var viewModel: EntriesViewModel
    
    private var state: ItemHighlightState { viewModel.states[book.id]! }
    
    var body: some View {
        Grid(horizontalSpacing: 18.0) {
            GridRow {
                CoverImageView(
                    with: book,
                    size: .thumb,
                    errorsViewModel
                )
                
                Grid(alignment: .leadingFirstTextBaseline, verticalSpacing: 4) {
                    GridRow {
                        Text(book.title).font(.headline)
                            .padding(.bottom, 2)
                    }
                    GridRow {
                        Text(book.author).font(.caption)
                    }
                    StatusTextRowView(book: book)
                    .font(.caption2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, state.isHovered(for: currentSurface) || state.isSelected ? 4 : 0)
                .gridCellColumns(Constants.nonImageGridCellColumns)
            }
        }
    }
}
