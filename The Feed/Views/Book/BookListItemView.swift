//
//  BookListItemView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

/**
 Shows a single book item for a list item view
 TODO: @dgattey draft status, rating?
 */
struct BookListItemView: View {
    let book: Book
    @Binding private var entry: Entry
    @Binding private var state: EntriesListItemView.ViewState
    
    @StateObject private var assetViewModel: AssetViewModel
    private let scaleFactorOnHover: CGFloat = 1.02
    
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
        HStack(spacing: 12) {
            imageWithProgress
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title).font(.headline)
                Text(book.author).font(.subheadline)
                Group {
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
            .padding(.leading, isHovered || isSelected ? 4 : 0)
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
                }
            }
        }
        .frame(width: 50, height: 75)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.separator, lineWidth: 1)
        )
        .rotationEffect(isHovered && !isSelected ? .degrees(degreesRotationOnHover) : .zero)
        .scaleEffect(isHovered && !isSelected ? scaleFactorOnHover : 1)
    }
}
