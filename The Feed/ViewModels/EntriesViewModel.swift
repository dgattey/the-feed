//
//  EntriesViewModel.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation
import Combine
import SwiftUI

/**
 Fetches and parses all entries for the entire list of entries. Pagination built in and will automatically load all subsequent pages until we have no more entries left to load.
 */
class EntriesViewModel: ViewModel {
    @Published var groupedEntries: [GroupedEntries] = []
    @Published var entries: [Entry] = []
    @Published var searchText: String = ""
    @Published var selectedTokens: [GroupedEntriesCategory] = []
    @Published var suggestedTokens = GroupedEntriesCategory.allCases.filter { category in
        // Remove all case
        return category != GroupedEntriesCategory.all
    }
    
    var filteredGroupedEntries: [GroupedEntries] {
        guard !searchText.isEmpty else {
            return groupedEntries
        }
        return groupedEntries.compactMap { group in
            // Hide categories that don't match current tokens
            if (selectedTokens.count > 0 && !selectedTokens.contains(group.category)) {
                return nil
            }
            // Return the whole group if the group name contains search term
            if (group.category.contains(searchText: searchText)) {
                return group
            }
            
            // Filter entries for the current group
            let filteredEntries = group.entries.filter { entry in
                entry.contains(searchText: searchText, withCategories: selectedTokens)
            }
            
            // Only return groups that have matching entries
            return filteredEntries.isEmpty ? nil : GroupedEntries(
                category: group.category,
                entries: filteredEntries
            )
        }
    }
    
    var filteredEntries: [Entry] {
        return entries.filter { $0.contains(searchText: searchText, withCategories: selectedTokens) }
    }
    
    /**
     Fetches data with optional limit/skip
     */
    func fetchData(withPagination pagination: Pagination = .default) {
        let publisher = NetworkManager.getDataTaskPublisher(
            forType: .entries,
            withPagination: pagination
        )
        fetchData(publisher) { dataSource in
            let entriesResponse: Entries = dataSource.value
            
            // Load more pages, or set us to stop loading
            if (entriesResponse.total > 0 && entriesResponse.limit + entriesResponse.skip < entriesResponse.total) {
                Task {
                    self.fetchData(withPagination: pagination.next())
                }
            } else if dataSource.origin == .network {
                self.isLoading = false
            }
            
            // Update entries depending on our current skip and then set grouped from it
            if (entriesResponse.skip == 0) {
                self.entries = entriesResponse.items
            } else {
                self.entries += entriesResponse.items
            }
            self.groupedEntries = EntriesViewModel.groupedEntries(fromResponse: self.entries)
        }
    }
    
    /**
     Groups and filters entries - by default uses all entries from `GroupedEntriesCategory` except `.all` and orders them the same way
     */
    private static func groupedEntries(fromResponse entries: [Entry]) -> [GroupedEntries] {
        GroupedEntriesCategory
            .allCases
            .filter { $0 != .all }
            .map { category in
                let filteredEntries = entries.filter { entry in
                    switch entry {
                    case .book:
                        return category == .book
                    case .location:
                        return category == .location
                    case .textBlock:
                        return category == .textBlock
                    }
                }
                return GroupedEntries(category: category, entries: filteredEntries)
            }
    }
}
