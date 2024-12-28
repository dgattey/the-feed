//
//  EntriesList.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/27/24.
//

import SwiftUI

struct EntriesListView: View {
    @ObservedObject var viewModel: EntriesViewModel
    @Binding var selectedEntry: Entry?
    
    var body: some View {
        List(selection: $selectedEntry) {
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
        .scrollContentBackground(.hidden)
        .background(Color.background.opacity(0.5))
        .refreshable {
            selectedEntry = nil
            viewModel.fetchData()
        }
        .navigationTitle("The Feed")
        .frame(alignment: .top)
        .toolbarBackground(Color.clear, for: .automatic)
#if os(iOS)
        .searchable(
            text: $viewModel.searchText,
            tokens: $viewModel.selectedTokens,
            suggestedTokens: $viewModel.suggestedTokens,
            placement: .navigationBarDrawer(displayMode:.always),
            prompt: Text("Search your feed"),
            token: { Text($0.rawValue) }
        )
        .listStyle(.plain)
        .onAppear() {
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableView.appearance().backgroundView = nil
            UITableViewCell.appearance().backgroundView = nil
        }
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
                        selectedEntry = nil
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
