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
    @State private var selectedItem: Entry? = nil
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
                await viewModel.fetchData()
            }
        }
    }
    
    private var entriesList: some View {
        List(viewModel.filteredGroupedEntries, selection: $selectedItem) { group in
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
        .refreshable { await viewModel.fetchData() }
        .searchable(text: $viewModel.searchText)
        .navigationTitle("The Feed")
#if os(macOS)
        // On macOS, show toolbar on the list view for refreshing without the sidebar toggle and react to esc to deselect all
        .toolbar { toolbarContent }
        .toolbar(removing: .sidebarToggle)
        .onKeyPress(.escape) {
            selectedItem = nil
            return .handled
        }
#endif
    }
    
    /**
     What shows up when you click an entry
     */
    private var entryDetail: some View {
        Group {
            if let unwrappedItem = selectedItem {
                EntryDetailView(entry: Binding(
                    get: { unwrappedItem },
                    set: { newValue in
                        // Update selectedItem with the new value
                        selectedItem = newValue
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
                        await viewModel.fetchData()
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
