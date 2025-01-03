//
//  GroupedEntries.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

enum GroupedEntriesCategory: String, SearchableModel, IdentifiableModel {
    case book = "Books"
    case location = "Locations"
    case textBlock = "Text blocks"
    
    var id: String { rawValue }
    
    static var allCases: Set<GroupedEntriesCategory> = [
        .book
    ]
    
    func contains(searchText: String) -> Bool {
        return id.localizedCaseInsensitiveContains(searchText)
    }
}

/**
 Groups together related entries with a title
 */
struct GroupedEntries: IdentifiableModel {
    var id: String {
        return category.id
    }

    let category: GroupedEntriesCategory
    var entries: [Entry]
}
