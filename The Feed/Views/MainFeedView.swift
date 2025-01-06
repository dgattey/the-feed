//
//  MainFeedView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/31/24.
//

import SwiftUI

fileprivate struct Constants {
    static let maxWidth: CGFloat = 600
    static let interItemSpacing: CGFloat = 16
    static let horizontalPadding: CGFloat = 24
    static let topOfPage = "topOfPageId"
}

struct MainFeedView: View {
    @EnvironmentObject var viewModel: EntriesViewModel
    
    /**
     Empty if there's something selected, otherwise a scroll view of entries or no results
     */
    var body: some View {
        Group {
            if viewModel.hasNoResults {
                NoResultsView(searchText: viewModel.searchText, layout: .withIcon)
            }
            feedOfEntries
        }
        .onHover { isHovered in
            // Clear when leaving the view
            if !isHovered {
                withAnimation {
                    viewModel.setHovered(.none)
                }
            }
        }
    }
    
    var feedOfEntries: some View {
        ScrollViewReader { scrollProxy in
            List(selection: $viewModel.selected) {
                Group {
                    Spacer().id(Constants.topOfPage)
                    VStack(spacing: Constants.interItemSpacing) {
                        EntryDetailView()
                        ForEach(viewModel.filtered) { entry in
                            ZStack {
                                EntryCardView(entry: Binding(get: {
                                    entry
                                }, set: { newEntry in
                                    viewModel.update(with: newEntry)
                                }))
                                
#if os(macOS)
                                // Not available on iOS!
                                CustomCursorView()
#endif
                            }
                            .padding(.horizontal, Constants.horizontalPadding)
                            .frame(maxWidth: Constants.maxWidth)
                            .onTapGesture {
                                // Animates both the detail view swap + the items in the item list going back to normal. We want to make this smooth otherwise there's weird artifacts on the detail view bouncing around.
                                withAnimation(.smooth) {
                                    viewModel.selected = entry
                                    scrollProxy.scrollTo(Constants.topOfPage)
                                }
                            }
                            .onHover { isHovered in
                                withAnimation {
                                    viewModel.setHovered(
                                        isHovered
                                        ? .valid(entry, surface: .feed)
                                        : .none
                                    )
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .background(.clear)
                .containerRelativeFrame(.horizontal, alignment: .center)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .background(.clear)
        .scrollContentBackground(.hidden)
#if os(iOS)
        // Reset for styling
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableView.appearance().backgroundView = nil
            UITableViewCell.appearance().backgroundView = nil
        }
#endif
    }
}
