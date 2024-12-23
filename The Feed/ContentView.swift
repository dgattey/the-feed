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
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .scaleEffect(2)
            } else if (viewModel.error != nil) {
                Section {
                    Text("Error")
                        .font(.title)
                        .foregroundColor(.red)
                    Text(viewModel.error!.localizedDescription)
                }
                .padding()
                .frame(maxWidth: 400)
            } else {
                NavigationView {
                    List {
                        ForEach($viewModel.entries) { $entry in
                            NavigationLink(destination: destinationView(for: entry)) {
                                switch entry {
                                case .book(let book):
                                    VStack {
                                        Text(book.title).font(.headline)
                                    }
                                case .unknown:
                                    VStack {
                                        Text("Unknown").font(.headline)
                                    }
                                }
                            }
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

@ViewBuilder
private func destinationView(for entry: Entry) -> some View {
    switch entry {
    case .book(let book):
        BookDetailView(book: book)
    case .unknown:
        UnknownDetailView()
    }
}
// Detail view for Book
struct BookDetailView: View {
    let book: Book

    var body: some View {
        Text("Details for \(book.title)")
            .font(.largeTitle)
            .padding()
    }
}

// Detail view for Unknown Entry
struct UnknownDetailView: View {
    var body: some View {
        Text("Details for unknown entry")
            .font(.largeTitle)
            .padding()
    }
}

#Preview {
    ContentView()
}
