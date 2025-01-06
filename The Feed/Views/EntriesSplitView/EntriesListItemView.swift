//
//  EntriesListItemView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/29/24.
//

import Combine
import SwiftUI

private let interItemSpacing: CGFloat = 4
private let insetPadding: CGFloat = 4
private let horizontalPadding: CGFloat = 6

/**
 Shows an individual entry in the list of all entries, to be clicked on.
 */
struct EntriesListItemView: View {
    @Binding var entry: Entry
    var scrollProxy: ScrollViewProxy
    @EnvironmentObject private var errorsViewModel: ErrorsViewModel
    @EnvironmentObject private var entriesViewModel: EntriesViewModel
    @EnvironmentObject private var currentSurface: CurrentSurface

    /**
     Current highlight state for this item
     */
    private var state: ItemHighlightState { entriesViewModel.states[entry.id]! }
    
    /**
     Offset the padding for the whole item when a book and selected, otherwise just show up the same as normal item padding.
     */
    private var verticalPadding: CGFloat {
        switch (entry.category, state.isSelected) {
        case (.book, false):
            return 4
        default:
            return -insetPadding
        }
    }
    
    /**
     Only books change leading padding when not selected, to hide it behind the cover image.
     */
    private var leadingPadding: CGFloat {
        switch (entry.category, state.isSelected) {
        case (.book, false):
            return 4
        default:
            return -horizontalPadding
        }
    }
    
    /**
     Trailing padding doesn't change but always goes outside the bounds of the item to account for standard item padding
     */
    private let trailingPadding: CGFloat = -horizontalPadding
    
    var body: some View {
        ZStack {
            NavigationLink(value: entry) {
                switch entry {
                case .book(let book):
                    BookListItemView(book: book)
                case .location(let location):
                    LocationListItemView(location: location)
                case .textBlock(let textBlock):
                    TextBlockListItemView(textBlock: textBlock)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.vertical, interItemSpacing)
            
            #if os(macOS)
            // Not available on iOS!
            CustomCursorView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(-interItemSpacing)
            #endif
        }
        .onChange(of: entriesViewModel.selected) {
            // Scroll the list to the selected item if it was selected elsewhere
            if entriesViewModel.selected?.id == entry.id {
                withAnimation {
                    scrollProxy.scrollTo(entry.id)
                }
            }
        }
        .listRowBackground(Color.clear)
        .onTapGesture {
            // Animates both the detail view swap + the items in the item list going back to normal. We want to make this smooth otherwise there's weird artifacts on the detail view bouncing around.
            withAnimation(.smooth) {
                entriesViewModel.selected = entry
            }
        }
        .onHover { isHovered in
            withAnimation {
                entriesViewModel.setHovered(
                    isHovered
                    ? .valid(entry, surface: .sidebar)
                    : .none
                )
            }
        }
        #if os(macOS)
        // We don't show background highlight on iOS
        .foregroundStyle(
            state.isHovered(for: currentSurface) || state.isSelected
            ? .accentForeground
            : .foreground
        )
        .background(highlightIndicator)
        #endif
    }
    
    /**
     On platforms that show a highlight (just macOS), this view can be the background behind the view
     */
    var highlightIndicator: some View {
        CardView(state)
        .padding(.vertical, verticalPadding)
        .padding(.leading, leadingPadding)
        .padding(.trailing, trailingPadding)
        .animation(.snappy(duration: 0.2), value: state)
    }
}
