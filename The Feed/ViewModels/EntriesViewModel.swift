//
//  EntriesViewModel.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation
import Combine

/**
 Fetches and parses all entries for the entire list of entries. Pagination not built in, will limit to first 100 items.
 TODO: @dgattey build pagination
 */
class EntriesViewModel: ObservableObject {
    @Published var groupedEntries = [GroupedEntries]()
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    var filteredGroupedEntries: [GroupedEntries] {
        if searchText.isEmpty {
            return groupedEntries
        } else {
            return groupedEntries.compactMap { group in
                // Return the whole group if the group name contains search term
                if (group.groupName.localizedCaseInsensitiveContains(searchText)) {
                    return group
                }
                
                // Filter entries for the current group
                let filteredEntries = group.entries.filter { entry in
                    entry.contains(searchText: searchText)
                }
                
                // Only return groups that have matching entries
                return filteredEntries.isEmpty ? nil : GroupedEntries(
                    groupName: group.groupName,
                    entries: filteredEntries
                )
            }
        }
    }
    
    func fetchData() async {
        DispatchQueue.main.sync {
            isLoading = true
        }
        
        // Create a promise to handle the async operation
        let result: Result<EntriesResponse, NetworkError> = await withCheckedContinuation { continuation in
            guard let publisher = ContentfulClient.getDataTaskPublisher(forType: .entries) else {
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
                self.isLoading = false
                self.groupedEntries = groupEntries(fromResponse: entriesResponse)
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
    private func groupEntries(fromResponse entries: EntriesResponse) -> [GroupedEntries] {
        let books = entries.items.filter { entry in
            if case .book(_) = entry {
                return true
            }
            return false
        }
        let locations = entries.items.filter { entry in
            if case .location(_) = entry {
                return true
            }
            return false
        }
        return [
            GroupedEntries(groupName: "Books", entries: books),
            GroupedEntries(groupName: "Locations", entries: locations)
        ]
    }
}
