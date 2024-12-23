//
//  EntriesToolbar.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

/**
 Shows a refresh button that fetches data for entries and shows loading status too
 */
struct EntriesToolbar: ToolbarContent {
    @ObservedObject var viewModel: EntriesViewModel
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: {
                Task {
                    await viewModel.fetchData()
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
