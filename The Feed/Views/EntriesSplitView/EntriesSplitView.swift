//
//  EntriesSplitView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import SwiftUI

/**
 Shows the entries list or an error page. Responsible for initializing the view model and handling all errors.
 */
struct EntriesSplitView: View {
    @StateObject private var viewModel = EntriesViewModel()
    
    var body: some View {
        VStack {
            if let error = viewModel.error {
                ErrorView(error: error)
            } else {
                NavigationSplitView {
                    entriesList
                } detail: {
                    entryDetail
                }
            }
        }
        .onAppear {
            Task {
                viewModel.fetchData()
            }
        }
    }
    
    private var entriesList: some View {
        List(selection: $viewModel.selectedEntry) {
            ForEach(viewModel.filteredGroupedEntries) { group in
                EntriesListSectionView(group: Binding(
                    get: { group },
                    set: { newGroup in
                        let index = viewModel.groupedEntries.firstIndex(of: group)
                        if let index {
                            viewModel.groupedEntries[index] = newGroup
                        } else {
                            viewModel.groupedEntries.append(newGroup)
                        }
                    }
                ))
            }
            noSearchResults
        }
        .refreshable {
            viewModel.fetchData()
        }
        .navigationTitle("The Feed")
        .frame(alignment: .top)
        #if os(iOS)
        .searchable(
            text: $viewModel.searchText,
            tokens: $viewModel.selectedTokens,
            suggestedTokens: $viewModel.suggestedTokens,
            placement: .navigationBarDrawer(displayMode:.always),
            prompt: Text("Search your feed"),
            token: { Text($0.rawValue) }
        )
        #else
        // On macOS, show toolbar on the list view for refreshing without the sidebar toggle and react to esc to deselect all
        .searchable(
            text: $viewModel.searchText,
            tokens: $viewModel.selectedTokens,
            suggestedTokens: $viewModel.suggestedTokens,
            placement: .sidebar,
            prompt: Text("Search your feed"),
            token: { Text($0.rawValue) }
        )
        .toolbar { toolbarContent }
        .toolbar(removing: .sidebarToggle)
        #endif
        .onReceive(NotificationCenter.default.publisher(for: .refreshData)) { _ in
            viewModel.fetchData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .deselectItem)) { _ in
            viewModel.selectedEntry = nil
        }
    }
    
    /**
     If the user has searched but there's nothing, show this view
     */
    private var noSearchResults: some View {
        Group {
            if viewModel.filteredGroupedEntries.isEmpty && !viewModel.searchText.isEmpty {
                Text("No results found for '\(viewModel.searchText)'")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .lineLimit(.max)
                    .padding(.vertical)
                    #if os(iOS)
                    .padding(.horizontal)
                    #endif
                    .containerRelativeFrame(.horizontal, alignment: .center)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    /**
     What shows up when you click an entry
     */
    private var entryDetail: some View {
        Group {
            if let unwrappedItem = viewModel.selectedEntry {
                EntryDetailView(entry: Binding(
                    get: { unwrappedItem },
                    set: { newValue in
                        // Update selectedItem with the new value
                        viewModel.selectedEntry = newValue
                    }
                ))
            } else {
                Text("Pick an entry").font(.title)
            }
        }
    }
    
    /**
     Shows a refresh button on the right side of the toolbar (only shows up on macOS
     */
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem {
                Spacer()
            }
            ToolbarItem {
                Button(action: {
                    Task {
                        viewModel.fetchData()
                    }
                }) {
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

#Preview {
    EntriesSplitView()
}
