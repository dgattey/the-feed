//
//  BookCardView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/31/24.
//

import SwiftUI

fileprivate struct Constants {
    static let coverToTextSpacing: CGFloat = 24.0
    static let interTextSpacing: CGFloat = 8.0
    static let cardPadding: CGFloat = 16.0
#if os(macOS)
    static let nonImageGridCellColumns = 3
    static let titleFont: Font = .title
    static let subtitleFont: Font = .headline
    static let captionFont: Font = .subheadline
    static let statusIconSize: CGFloat = 20
#else
    static let nonImageGridCellColumns = 3
    static let titleFont: Font = .headline
    static let subtitleFont: Font = .caption
    static let captionFont: Font = .caption2
    static let statusIconSize: CGFloat = 16
#endif
}

/**
 Shows a single book item for a list item view
 */
struct BookCardView: View {
    let book: Book
    @EnvironmentObject private var errorsViewModel: ErrorsViewModel
    @EnvironmentObject private var viewModel: EntriesViewModel
    @EnvironmentObject private var currentSurface: CurrentSurface
    
    private var state: ItemHighlightState { viewModel.states[book.id]! }
    private var isHovered: Bool { state.isHovered(for: currentSurface) }
    
    var body: some View {
        Grid(horizontalSpacing: Constants.coverToTextSpacing) {
            GridRow {
                CoverImageView(
                    with: book,
                    size: .card,
                    errorsViewModel
                )
                
                Grid(alignment: .leadingFirstTextBaseline, verticalSpacing: Constants.interTextSpacing) {
                    GridRow {
                        Text(book.title).font(Constants.titleFont).bold()
                    }
                    GridRow {
                        Text(book.author).font(Constants.subtitleFont).fontWeight(.regular)
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
                    .font(Constants.captionFont)
                }
                .foregroundStyle(
                    isHovered ? .accentForeground : .foreground
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .gridCellColumns(Constants.nonImageGridCellColumns)
                
                statusIcon
            }
        }
        .padding(.vertical, Constants.cardPadding)
        .padding(.leading, -Constants.cardPadding)
        .background(CardView(hasClearBackground: false, state, showsSelection: false))
    }
    
    private var statusIcon: some View {
        Group {
            if book.readDateFinished != nil {
                Image(systemName: "checkmark.circle.fill")
            } else if book.readDateStarted != nil {
                Image(systemName: "book.fill")
            } else if book.sysContent.createdAt != nil {
                Image(systemName: "bookmark.fill")
            }
        }
        .font(.system(size: Constants.statusIconSize))
        .foregroundStyle(.foreground.opacity(0.75))
        .symbolRenderingMode(.hierarchical)
        .gridCellAnchor(.topTrailing)
        .padding(.trailing, Constants.interTextSpacing)
    }
}
