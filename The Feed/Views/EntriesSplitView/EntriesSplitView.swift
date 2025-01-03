//
//  EntriesSplitView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import SwiftUI


fileprivate struct Constants {
    static let minListWidth: CGFloat = 200
    static let idealListWidth: CGFloat = 300
    static let minDetailColumnWidth: CGFloat = 300
    static let maxDetailColumnWidth: CGFloat = 600
}

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
                EntriesListView(selectedEntry: $selectedEntry)
                    .environmentObject(viewModel)
                    .navigationSplitViewColumnWidth(min: Constants.minListWidth, ideal: Constants.idealListWidth)
            } detail: {
                entryDetail
                    .navigationSplitViewColumnWidth(min: Constants.minDetailColumnWidth, ideal: Constants.maxDetailColumnWidth)
                    .frame(minWidth: 0, maxWidth: Constants.maxDetailColumnWidth, alignment: .center)
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
