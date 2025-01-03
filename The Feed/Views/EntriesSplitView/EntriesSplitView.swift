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
    static let minDetailWidth: CGFloat = 300
    static let idealDetailWidth: CGFloat = 600
    static let minHeight: CGFloat = 200
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
        VStack(spacing: 0) {
            NavigationSplitView {
                EntriesListView(selectedEntry: $selectedEntry)
                    .navigationSplitViewColumnWidth(min: Constants.minListWidth, ideal: Constants.idealListWidth)
            } detail: {
                scrollableDetailPane
                    .navigationSplitViewColumnWidth(min: Constants.minDetailWidth, ideal: Constants.idealDetailWidth)
            }
            .background(Color.clear)
            .frame(maxHeight: .infinity)
            
            ErrorsView()
        }
        .environmentObject(viewModel)
        .frame(minHeight: Constants.minHeight)
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
     Wraps the contents of the detail
     */
    private var scrollableDetailPane: some View {
        ZStack {
            ScrollView {
                detailPane
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
            
            macTitleBarBackground
        }
    }
    
    /**
     For macOS, put a background and separator behind the title bar on just the detail side.
     */
    private var macTitleBarBackground: some View {
        Group {
#if os(macOS)
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.backgroundGlass)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .frame(height: 39)
                Rectangle()
                    .fill(.separator)
                    .frame(height: 0.5)
                Spacer()
            }
            .padding(.top, -39)
#endif
        }
    }
    
    /**
     Entry detail view or what shows up when you have nothing selected
     */
    private var detailPane: some View {
        Group {
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
