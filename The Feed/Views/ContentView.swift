//
//  ContentView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedItem: Entry? = nil
    @ObservedObject var viewModel = EntriesViewModel()
    
    var body: some View {
        VStack {
            if let error = viewModel.error {
                ErrorView(error: error)
            } else {
                NavigationSplitView {
                    List($viewModel.entries, selection: $selectedItem) { $entry in
                        ListItemView(entry: $entry)
                    }
                    .refreshable {
                        await viewModel.fetchData()
                    }
                    .navigationTitle("The Feed")
#if os(macOS)
                    // On macOS, show toolbar on the list view for refreshing without the sidebar toggle and react to esc to deselect all
                    .toolbar {
                        EntriesToolbar(viewModel: viewModel)
                    }
                    .toolbar(removing: .sidebarToggle)
                    .onKeyPress(.escape) {
                        selectedItem = nil
                        return .handled
                    }
#endif
                } detail: {
                    if let item = selectedItem {
                        DetailView(entry: item)
                    } else {
                        Text("Pick an entry").font(.title)
                    }
                }
                
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchData()
            }
        }
    }
}

#Preview {
    ContentView()
}
