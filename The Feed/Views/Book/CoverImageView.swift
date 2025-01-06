//
//  CoverImageView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/31/24.
//

import SwiftUI

fileprivate struct Constants {
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
 Fetches and shows a cover image
 */
struct CoverImageView: View {
    let book: Book
    @StateObject private var viewModel: AssetViewModel
    @EnvironmentObject private var entriesViewModel: EntriesViewModel
    @EnvironmentObject private var currentSurface: CurrentSurface
    
    init(with book: Book,
         _ errorsViewModel: ErrorsViewModel
    ) {
        self.book = book
        _viewModel = StateObject(
            wrappedValue:
                AssetViewModel(book.coverImage, errorsViewModel: errorsViewModel))
    }
    
    private var state: ItemHighlightState { entriesViewModel.states[book.id]! }
    
    /**
     A slightly random number of degrees for rotation when hovered
     */
    private var degreesRotationOnHover: Double {
        return Double(book.id.hashValue % 2) - 2
    }
    
    var body: some View {
        ZStack {
            Color.background
            
            // Either loading, the decoded image, or the ! to show failure
            if viewModel.isLoading && viewModel.image == nil {
                ProgressView()
            } else if let image = viewModel.image {
                image.resizable()
            } else {
                Group {
                    Image(systemName: "exclamationmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.foreground)
                        .frame(maxHeight: Constants.maxErrorImageHeight)
                }
                .padding(Constants.errorImagePadding)
            }
        }
        .cornerRadius(Constants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(.separator, lineWidth: 1)
                .foregroundStyle(Color.foreground)
        )
        .aspectRatio(Constants.aspectRatio, contentMode: .fill)
        .frame(minWidth: Constants.minWidth, maxWidth: Constants.maxWidth)
        .rotationEffect(
            state
                .isHovered(for: currentSurface) && !state.isSelected ?
                .degrees(degreesRotationOnHover) : .zero
        )
        .scaleEffect(
            state
                .isHovered(
                    for: currentSurface
                ) && !state.isSelected ? Constants.hoverScaleFactor : 1
        )
        .onAppear {
            let queue = DispatchQueue.global(qos: .utility)
            queue.async {
                viewModel.fetchData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshData)) { _ in
            viewModel.resetAndFetch()
        }
    }
}
