//
//  NoResultsView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/31/24.
//

import SwiftUI

enum Layout {
    case text
    case withIcon
}

/**
 Shows a text-based no results view
 */
struct NoResultsView: View {
    var searchText: String
    var layout: Layout
    
    var body: some View {
        Group {
            switch layout {
            case .text: textLayout
            case .withIcon: withIconLayout
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .foregroundColor(.gray)
        .lineLimit(.max)
        .padding(.vertical, 32)
        .padding(.horizontal)
        .containerRelativeFrame(.horizontal, alignment: .center)
        .multilineTextAlignment(.center)
    }
    
    var textLayout: some View {
        Text("No results found for '\(searchText)'")
            .font(.headline)
    }
    
    var withIconLayout: some View {
        VStack(spacing: 24) {
            Circle()
                .fill(Color.accentColor)
                .stroke(.separator, lineWidth: 1)
                .frame(width: 128, height: 128)
                .overlay(content: {
                    Image(systemName: "questionmark")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(.accentForeground)
                })
            Text("Nothing here")
                .font(.title)
        }
    }
}
