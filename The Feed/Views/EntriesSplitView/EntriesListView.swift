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
    @EnvironmentObject var errorsViewModel: ErrorsViewModel
    @EnvironmentObject var viewModel: EntriesViewModel
    
    var body: some View {
        list
            .onReceive(NotificationCenter.default.publisher(for: .refreshData)) { _ in
                DispatchQueue.main.async {
                    withAnimation {
                        resetAndFetch()
                    }
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
            .onAppear {
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
     Just the list itself for better typechecking perf
     */
    private var list: some View {
        ScrollViewReader { scrollProxy in
            List(selection: $viewModel.selected) {
                ForEach(viewModel.groupedAndFiltered) { group in
                    EntriesListSectionView(
                        category: group.category,
                        entries: group.entries,
                        scrollProxy: scrollProxy
                    )
                }
                
                if viewModel.hasNoResults {
                    NoResultsView(searchText: viewModel.searchText, layout: .text)
                }
            }
        }
        .onHover { isHovered in
            // Extra clear for leaving this parent view
            if !isHovered {
                withAnimation {
                    viewModel.setHovered(.none)
                }
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
                        NotificationCenter.default.postRefreshData()
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
     Animates a reset and fetch of new data, clearing current selection and hover if needed
     */
    private func resetAndFetch() {
        withAnimation {
            errorsViewModel.reset()
            let queue = DispatchQueue.global(qos: .utility)
            queue.async {
                viewModel.fetchData()
            }
        }
    }
}
