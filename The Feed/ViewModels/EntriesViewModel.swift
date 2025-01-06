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
    enum HoveredEntry {
        case valid(_ entry: Entry, surface: Surface)
        case none
    }
    
    @Published private var rawEntries: [Entry] = [] {
        willSet {
            // Clear selected if it will no longer be valid
            if let selected, !newValue.contains(where: { $0.id == selected.id }) {
                withAnimation(.smooth) {
                    self.selected = nil
                }
            }
            
            // Clear hovered if it will no longer be valid
            if let hovered, !newValue.contains(where: { $0.id == hovered.id }) {
                withAnimation(.smooth) {
                    self.hovered = nil
                }
            }
        }
    }
    
    @Published var searchText: String = ""
    @Published var selectedTokens: [GroupedEntriesCategory] = []
    @Published var suggestedTokens = Array(GroupedEntriesCategory.allCases)
    
    /**
     Currently selected entry
     */
    @Published var selected: Entry? = nil
    
    /**
     Currently hovered entry
     */
    @Published private(set) var hovered: Entry? = nil
    
    /**
     If hovered, which list
     */
    @Published private(set) var hoveredSurface: Surface? = nil
    
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
     Computed based off current hovered/selected and raw entry state
     */
    var states: [String: ItemHighlightState] {
        Dictionary(uniqueKeysWithValues: rawEntries.map { entry in
            let isHovered = hovered?.id == entry.id
            let isSelected = selected?.id == entry.id
            return (
                entry.id,
                ItemHighlightState(
                    isHovered: isHovered,
                    isSelected: isSelected,
                    surface: hoveredSurface
                )
            )
        }
)
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
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
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
     Sets the hovered entry + surface together
     */
    func setHovered(_ hoveredEntry: HoveredEntry) {
        switch hoveredEntry {
        case .none:
            self.hovered = nil
            self.hoveredSurface = nil
        case .valid(let entry, let surface):
            self.hovered = entry
            self.hoveredSurface = surface
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
        
        // Clear selected if it will no longer be valid
        if let selected, selected.id == newEntry.id {
            self.selected = nil
        }
        
        // Clear hovered if it will no longer be valid
        if let hovered, hovered.id == newEntry.id {
            self.hovered = nil
        }
    }
}
