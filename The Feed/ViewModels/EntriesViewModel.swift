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
class EntriesViewModel: ObservableObject {
    @Published var groupedEntries: [GroupedEntries] = []
    @Published var entries: [Entry] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText: String = ""
    @Published var selectedTokens: [GroupedEntriesCategory] = []
    @Published var suggestedTokens = GroupedEntriesCategory.allCases.filter { category in
        // Remove all case
        return category != GroupedEntriesCategory.all
    }
    
    private var cancellables = Set<AnyCancellable>()
    
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
    func fetchData(withPagination pagination: Pagination = .default) async {
        DispatchQueue.main.sync {
            isLoading = true
        }
        
        // Create a promise to handle the async operation
        let result: Result<EntriesResponse, NetworkError> = await withCheckedContinuation { continuation in
            guard let publisher = ContentfulClient.getDataTaskPublisher(
                forType: .entries,
                withPagination: pagination
            ) else {
                continuation.resume(returning: .failure(.invalidResponse))
                return
            }
            
            publisher
                .decode(type: EntriesResponse.self, decoder: JSONDecoder())
                .mapError { error in
                    if let decodingError = error as? DecodingError {
                        return NetworkError.decodingError(decodingError)
                    }
                    return NetworkError.invalidResponse
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        continuation.resume(returning: .failure(error))
                    }
                }, receiveValue: { entries in
                    continuation.resume(returning: .success(entries))
                })
                .store(in: &cancellables)
        }
        
        // Handle the result of the async operation
        switch result {
        case .success(let entriesResponse):
            DispatchQueue.main.sync {
                // Load more pages, or set us to stop loading
                if (entriesResponse.limit + entriesResponse.skip < entriesResponse.total) {
                    Task {
                        await self.fetchData(withPagination: pagination.next())
                    }
                } else {
                    self.isLoading = false
                }
                
                // Update entries depending on our current skip and then set grouped from it
                if (entriesResponse.skip == 0) {
                    self.entries = entriesResponse.items
                } else {
                    self.entries += entriesResponse.items
                }
                self.groupedEntries = groupEntries(fromResponse: self.entries)
            }
        case .failure(let error):
            DispatchQueue.main.sync {
                self.isLoading = false
                self.error = error.localizedDescription
            }
        }
    }
    
    /**
     Groups and filters entries
     */
    private func groupEntries(fromResponse entries: [Entry]) -> [GroupedEntries] {
        let books = entries.filter { entry in
            if case .book(_) = entry {
                return true
            }
            return false
        }
        let locations = entries.filter { entry in
            if case .location(_) = entry {
                return true
            }
            return false
        }
        return [
            GroupedEntries(category: .book, entries: books),
            GroupedEntries(category: .location, entries: locations)
        ]
    }
}
