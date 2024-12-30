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
    @StateObject private var viewModel: EntriesViewModel
    @State private var selectedEntry: Entry? = nil
    
    init(_ errorsViewModel: ErrorsViewModel) {
        _viewModel = StateObject(wrappedValue: EntriesViewModel(errorsViewModel))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationSplitView {
                EntriesListView(viewModel: viewModel, selectedEntry: $selectedEntry)
                    .navigationSplitViewColumnWidth(min: 200, ideal: 300)
            } detail: {
                entryDetail
                    .navigationSplitViewColumnWidth(min: 300, ideal: 600)
            }
            .background(Color.clear)
            .frame(maxHeight: .infinity)
            
            ErrorsView()
        }
        .frame(minHeight: 200)
        .onAppear {
            Task {
                withAnimation {
                    selectedEntry = nil
                    let queue = DispatchQueue.global(qos: .utility)
                    queue.async {
                        viewModel.fetchData()
                    }
                }
            }
        }
    }
    
    /**
     What shows up when you click an entry
     */
    private var entryDetail: some View {
        ZStack {
            #if os(macOS)
            // Add a background to the title bar on mac
            VStack(spacing: 0) {
                Color.clear.ignoresSafeArea().frame(height: 39)
                Rectangle().fill(.separator).frame(height: 0.5)
                Spacer()
            }
            .padding(.top, -39)
            #endif
            
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
