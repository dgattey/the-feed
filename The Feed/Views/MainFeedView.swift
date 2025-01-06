//
//  MainFeedView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/31/24.
//

import SwiftUI

struct MainFeedView: View {
    @EnvironmentObject var viewModel: EntriesViewModel
    
    /**
     Empty if there's something selected, otherwise a scroll view of entries or no results
     */
    var body: some View {
        Group {
            if viewModel.selected != nil {
                EmptyView()
            } else {                
                if viewModel.hasNoResults {
                    NoResultsView(searchText: viewModel.searchText, layout: .withIcon)
                } else {
                    feedOfEntries
                }
            }
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
        List(selection: $viewModel.selected) {
            Spacer()
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
                .frame(maxWidth: 400)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .onTapGesture {
                    // Animates both the detail view swap + the items in the item list going back to normal. We want to make this smooth otherwise there's weird artifacts on the detail view bouncing around.
                    withAnimation(.smooth) {
                        viewModel.selected = entry
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
            .containerRelativeFrame(.horizontal, alignment: .center)
            Spacer()
        }
        .listStyle(.plain)
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
