//
//  ContentView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = EntryViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.entry, id: \.sys.id) { entry in
                VStack(alignment: .leading) {
                    Text(entry.sys.id)
                        .font(.headline)
                }
                .navigationTitle("All entries")
            }
            .onAppear {
                self.viewModel.fetchData()
            }
        }
    }
}

#Preview {
    ContentView()
}
