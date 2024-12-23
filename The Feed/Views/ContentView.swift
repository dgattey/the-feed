//
//  ContentView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = EntriesViewModel()
    
    var body: some View {
        VStack {
            if (viewModel.isLoading) {
                LoadingView()
            } else if let error = viewModel.error {
                ErrorView(error: error)
            } else {
                NavigationView {
                    List {
                        ForEach($viewModel.entries) { $entry in
                            ListItemView(entry: entry)
                        }
                    }
                    .navigationTitle("All books")
                }
            }
        }
        .onAppear {
            self.viewModel.fetchData()
        }
    }
}

#Preview {
    ContentView()
}
