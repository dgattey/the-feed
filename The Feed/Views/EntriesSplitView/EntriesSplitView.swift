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
    @ObservedObject private var viewModel = EntriesViewModel()
    @State private var selectedEntry: Entry? = nil
    
    var body: some View {
        VStack {
            if let error = viewModel.error {
                ErrorView(error: error)
            } else {
                NavigationSplitView {
                    EntriesListView(viewModel: viewModel, selectedEntry: $selectedEntry)
                        .navigationSplitViewColumnWidth(min: 200, ideal: 300)
                } detail: {
                    entryDetail
                }
                .background(Color.clear)
            }
        }
        .onAppear {
            Task {
                selectedEntry = nil
                viewModel.fetchData()
            }
        }
        .onKeyPress(.escape) {
            selectedEntry = nil
            return .handled
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshData)) { _ in
            selectedEntry = nil
            viewModel.fetchData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .deselectItem)) { _ in
            selectedEntry = nil
        }
    }
    
    /**
     What shows up when you click an entry
     */
    private var entryDetail: some View {
        ZStack {
            Color.background.opacity(0.5).ignoresSafeArea()
            if let unwrappedItem = selectedEntry {
                EntryDetailView(entry: Binding(
                    get: { unwrappedItem },
                    set: { newValue in
                        selectedEntry = newValue
                    }
                ))
            } else {
                Text("Pick an entry").font(.title)
            }
        }
    }
}

#Preview {
    EntriesSplitView()
}
