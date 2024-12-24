//
//  GroupedEntries.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

/**
 Groups together related entries with a title
 */
struct GroupedEntries: Codable, Hashable, Identifiable {
    var id: String {
        return groupName
    }

    let groupName: String
    var entries: [Entry]
}
