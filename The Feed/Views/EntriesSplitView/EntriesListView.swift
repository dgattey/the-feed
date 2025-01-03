//
//  EntriesList.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/27/24.
//

import SwiftUI

fileprivate struct Constants {
    #if os(macOS)
    static let searchFieldPlacement: SearchFieldPlacement = .sidebar
    static let listStyle = SidebarListStyle.sidebar
    #else
    static let searchFieldPlacement: SearchFieldPlacement = .navigationBarDrawer(displayMode:.always)
    static let listStyle = PlainListStyle.plain
    #endif
}

struct EntriesListView: View {
    @Binding var selectedEntry: Entry?
    @State var hoveredEntry: Entry?
    @EnvironmentObject var errorsViewModel: ErrorsViewModel
    @EnvironmentObject var viewModel: EntriesViewModel
    
    var body: some View {
        List(selection: $selectedEntry) {
            ForEach(viewModel.groupedAndFiltered) { group in
                EntriesListSectionView(
                    selectedEntry: $selectedEntry,
                    hoveredEntry: $hoveredEntry,
                    category: group.category,
                    entries: group.entries
                )
            }
            
            noSearchResults
        }
        .onKeyPress(.escape) {
            withAnimation {
                selectedEntry = nil
                hoveredEntry = nil
            }
            return .handled
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshData)) { _ in
            resetAndFetch()
        }
        .onReceive(NotificationCenter.default.publisher(for: .deselectItem)) { _ in
            withAnimation {
                selectedEntry = nil
                hoveredEntry = nil
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.backgroundGlass)
        .refreshable {
            resetAndFetch()
        }
        .navigationTitle("The Feed")
        .frame(alignment: .top)
        .searchable(
            text: $viewModel.searchText,
            tokens: $viewModel.selectedTokens,
            suggestedTokens: $viewModel.suggestedTokens,
            placement: Constants.searchFieldPlacement,
            prompt: Text("Search your feed"),
            token: { Text($0.rawValue) }
        )
        .listStyle(Constants.listStyle)
#if os(iOS)
        // Reset for styling
        .onAppear() {
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableView.appearance().backgroundView = nil
            UITableViewCell.appearance().backgroundView = nil
        }
#else
        // Just shows up on macOS
        .toolbar { toolbarContent }
        .toolbarBackground(Color.clear, for: .windowToolbar)
#endif
    }
    
    /**
     If the user has searched but there's nothing, show this view
     */
    private var noSearchResults: some View {
        Group {
            if viewModel.filteredGroupedEntries.isEmpty && !viewModel.searchText.isEmpty {
                Text("No results found for '\(viewModel.searchText)'")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .lineLimit(.max)
                    .padding(.vertical, 32)
                    .padding(.horizontal)
                    .containerRelativeFrame(.horizontal, alignment: .center)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    /**
     Shows a refresh button on the right side of the toolbar (only shows up on macOS)
     */
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem {
                Spacer()
            }
            ToolbarItem {
                Button(action: {
                    Task {
                        resetAndFetch()
                    }
                }) {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.accent)
                                .controlSize(.small)
                        } else {
                            Label("", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
        }
    }
    
    /**
     Animates a reset and fetch of new data, clearing current selection and hover preemptively
     */
    private func resetAndFetch() {
        withAnimation {
            selectedEntry = nil
            hoveredEntry = nil
            errorsViewModel.reset()
            let queue = DispatchQueue.global(qos: .utility)
            queue.async {
                viewModel.fetchData()
            }
        }
    }
}
