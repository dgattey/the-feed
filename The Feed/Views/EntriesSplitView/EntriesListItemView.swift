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
    @Binding var selectedEntry: Entry?
    @Binding var hoveredEntry: Entry?
    @EnvironmentObject var errorsViewModel: ErrorsViewModel
    
    enum ViewState {
        case normal
        case hovered
        case selected
        case hoveredAndSelected
    }
    
    private var state: ViewState {
        switch (isHovered, isSelected) {
        case (true, true): return .hoveredAndSelected
        case (true, false): return .hovered
        case (false, true): return .selected
        case (false, false): return .normal
        }
    }
    
    private var isHovered: Bool {
        return hoveredEntry?.id == entry.id
    }
    
    private var isSelected: Bool {
        return selectedEntry?.id == entry.id
    }
    
    /**
     Offset the padding for the whole item when a book and selected, otherwise just show up the same as normal item padding.
     */
    private var verticalPadding: CGFloat {
        switch (entry.category, isSelected) {
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
        switch (entry.category, isSelected) {
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
                    BookListItemView(
                        with: book,
                        andWrappingEntry: $entry,
                        Binding(
                            get: {
                                state
                            }, set: { newState, _ in
                                
                            }
                        ),
                        errorsViewModel
                    )
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
        .listRowBackground(Color.clear)
        .onTapGesture {
            // Animates both the detail view swap + the items in the item list going back to normal. We want to make this smooth otherwise there's weird artifacts on the detail view bouncing around.
            withAnimation(.smooth) {
                selectedEntry = entry
            }
        }
        .onHover { isHovered in
            if isHovered && hoveredEntry?.id != entry.id {
                withAnimation {
                    hoveredEntry = entry
                }
            } else if !isHovered && hoveredEntry?.id == entry.id {
                withAnimation {
                    hoveredEntry = nil
                }
            }
        }
        #if os(macOS)
        // We don't show background highlight on iOS
        .foregroundStyle(isHovered || isSelected ? .accentForeground : .foreground)
        .background(highlightIndicator)
        #endif
    }
    
    /**
     On platforms that show a highlight (just macOS), this view can be the background behind the view
     */
    var highlightIndicator: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill({
                if isSelected || isHovered {
                    return Color.backgroundAccent
                }
                return Color.clear
            }())
            .frame(maxHeight: isSelected ? .infinity : 60)
            .padding(.vertical, verticalPadding)
            .padding(.leading, leadingPadding)
            .padding(.trailing, trailingPadding)
            .animation(.snappy(duration: 0.2), value: state)
    }
}
