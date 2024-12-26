//
//  GroupedEntries.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

enum GroupedEntriesCategory: String, CaseIterable, SearchableEntry, Identifiable {
    case all = "All"
    case book = "Books"
    case location = "Locations"
    case textBlock = "Text blocks"
    
    var id: String { rawValue }
    func contains(searchText: String) -> Bool {
        return id.localizedCaseInsensitiveContains(searchText)
    }
}

/**
 Groups together related entries with a title
 */
struct GroupedEntries: Codable, Hashable, Identifiable {
    var id: String {
        return category.id
    }

    let category: GroupedEntriesCategory
    var entries: [Entry]
}
