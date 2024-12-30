//
//  BookListItemView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

fileprivate struct CoverImage {
    static let cornerRadius: CGFloat = 6
    static let hoverScaleFactor: CGFloat = 1.02
    static let aspectRatio: CGFloat = 1/1.5
    static let errorImagePadding: CGFloat = 16
    
    #if os(macOS)
    static let minWidth: CGFloat = 40
    static let maxWidth: CGFloat = 64
    static let maxErrorImageHeight: CGFloat = 40
    static let nonImageGridCellColumns = 4
    #else
    static let minWidth: CGFloat = 32
    static let maxWidth: CGFloat = 44
    static let maxErrorImageHeight: CGFloat = 36
    static let nonImageGridCellColumns = 5
    #endif
}

/**
 Shows a single book item for a list item view
 TODO: @dgattey draft status, rating?
 */
struct BookListItemView: View {
    let book: Book
    @Binding private var entry: Entry
    @Binding private var state: EntriesListItemView.ViewState
    
    @StateObject private var assetViewModel: AssetViewModel
    
    private var isSelected: Bool {
        return state == .hoveredAndSelected || state == .selected
    }
    
    private var isHovered: Bool {
        return state == .hoveredAndSelected || state == .hovered
    }
    
    /**
     A slightly random number of degrees for rotation when hovered
     */
    private var degreesRotationOnHover: Double {
        return Double(book.id.hashValue % 2) - 2
    }
    
    init(with book: Book,
         andWrappingEntry entry: Binding<Entry>,
         _ state: Binding<EntriesListItemView.ViewState>,
         _ errorsViewModel: ErrorsViewModel
    ) {
        self.book = book
        _state = state
        _entry = entry
        _assetViewModel = StateObject(
            wrappedValue:
                AssetViewModel(book.coverImage, errorsViewModel: errorsViewModel))
    }
    
    var body: some View {
        mainContent
        .onAppear {
            if (
                !book.coverImage.id.isEmpty &&
                !assetViewModel.isLoading &&
                (assetViewModel.asset == nil || assetViewModel.image == nil)
            ) {
                let queue = DispatchQueue.global(qos: .utility)
                queue.async {
                    assetViewModel.fetchData()
                }
            }
        }
    }
    
    var mainContent: some View {
        Grid(horizontalSpacing: 18.0) {
            GridRow {
                imageWithProgress
                
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
                .padding(.leading, isHovered || isSelected ? 4 : 0)
                .gridCellColumns(CoverImage.nonImageGridCellColumns)
            }
        }
    }
    
    var imageWithProgress: some View {
        ZStack {
            Color.background
            
            // Either loading, the decoded image, or the ! to show failure
            if assetViewModel.isLoading && assetViewModel.image == nil {
                ProgressView()
            } else if let image = assetViewModel.image {
                image.resizable()
            } else {
                Group {
                    Image(systemName: "exclamationmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.foreground)
                        .frame(maxHeight: CoverImage.maxErrorImageHeight)
                }
                .padding(CoverImage.errorImagePadding)
            }
        }
        .cornerRadius(CoverImage.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: CoverImage.cornerRadius)
                .stroke(.separator, lineWidth: 1)
                .foregroundStyle(Color.foreground)
        )
        .aspectRatio(CoverImage.aspectRatio, contentMode: .fill)
        .frame(minWidth: CoverImage.minWidth, maxWidth: CoverImage.maxWidth)
        .rotationEffect(isHovered && !isSelected ? .degrees(degreesRotationOnHover) : .zero)
        .scaleEffect(isHovered && !isSelected ? CoverImage.hoverScaleFactor : 1)
    }
}
