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
    var category: GroupedEntriesCategory
    var entries: [Entry]
    var scrollProxy: ScrollViewProxy
    
    @EnvironmentObject var viewModel: EntriesViewModel
    
    var body: some View {
        Section(header: Text(category.id)) {
            ForEach(entries) { entry in
                EntriesListItemView(
                    entry: Binding(
                        get: { entry },
                        set: { viewModel.update(with: $0) }
                    ),
                    scrollProxy: scrollProxy
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
