//
//  EntriesListSectionView.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import SwiftUI

/**
 Shows a section in the list view for entries - shows a group name and entries below.
 */
struct EntriesListSectionView: View {
    @Binding var selectedEntry: Entry?
    @Binding var hoveredEntry: Entry?
    var category: GroupedEntriesCategory
    var entries: [Entry]
    
    @EnvironmentObject var viewModel: EntriesViewModel
    
    var body: some View {
        Section(header: Text(category.id)) {
            ForEach(entries) { entry in
                EntriesListItemView(
                    entry: Binding(get: {
                        entry
                    }, set: { newEntry in
                        viewModel.update(with: entry)
                    }),
                    selectedEntry: $selectedEntry,
                    hoveredEntry: $hoveredEntry
                )
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
#if os(iOS)
        // Not available on macOS
        .listSectionSpacing(.custom(24))
#endif
    }
}
