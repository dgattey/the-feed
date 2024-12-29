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
    @Binding var group: GroupedEntries
    
    var body: some View {
        Section(header: Text(group.id)) {
            ForEach($group.entries) { $entry in
                EntriesListItemView(
                    entry: $entry,
                    selectedEntry: $selectedEntry,
                    hoveredEntry: $hoveredEntry
                )
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
#if os(iOS)
        .listSectionSpacing(.custom(24))
#endif
    }
}
