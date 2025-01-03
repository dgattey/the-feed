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
    @Published private var rawEntries: [Entry] = []
    
    @Published var searchText: String = ""
    @Published var selectedTokens: [GroupedEntriesCategory] = []
    @Published var suggestedTokens = Array(GroupedEntriesCategory.allCases)
    
    /**
     Currently applied category filters, from selected/suggested tokens
     */
    private var categoryFilters: Set<GroupedEntriesCategory> {
        if selectedTokens.isEmpty {
            return Set(suggestedTokens)
        }
        return Set(selectedTokens)
    }
    
    /**
     Applies sort & filter logic to all entries while still allowing binding
     */
    var filtered: [Entry] {
        rawEntries
            .filtered(byCategories: categoryFilters, searchText: searchText)
            .sorted
    }
    
    /**
     Applies sort & filter logic to all enabled groups holding the entries
     */
    var groupedAndFiltered: [GroupedEntries] {
        self.categoryFilters
            .map { category in
                let entriesForGroup = rawEntries
                    .filtered(byCategories: [category], searchText: searchText)
                    .sorted
                return GroupedEntries(category: category, entries: entriesForGroup)
            }
            .compactMap { $0.entries.isEmpty ? nil : $0 }
    }
    
    /**
     Use to check if we should show a "no results" view
     */
    var hasNoResults: Bool {
        filtered.isEmpty && !searchText.isEmpty
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
            withAnimation {
                if (entriesResponse.skip == 0) {
                    self.rawEntries = entriesResponse.items
                } else {
                    self.rawEntries += entriesResponse.items
                }
            }
        }
    }
    
    /**
     Call this from an update for a binding so that we can update the base entry model when we make changes.
     */
    func update(with newEntry: Entry) {
        let index = rawEntries.firstIndex(where: {
            $0.id == newEntry.id
        })
        guard let index else {
            print("Couldn't find \(newEntry.id), appending")
            rawEntries.append(newEntry)
            return
        }
        rawEntries[index] = newEntry
    }
}
