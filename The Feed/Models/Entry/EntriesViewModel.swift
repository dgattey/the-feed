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
    @Published var entries = [Entry]()
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData() -> Void {
        isLoading = true
        guard let publisher = ContentfulClient.getDataTaskPublisher(forType: .entries) else {
            error = "Could not build request"
            return
        }
        publisher
            .decode(type: Entries.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        self.error = networkError.errorDescription
                    } else {
                        self.error = "An unexpected error occurred."
                    }
                }
            }, receiveValue: { entries in
                self.entries = entries.items.filter { entry in
                    switch entry {
                    case .unknown:
                        return false
                    default:
                        return true
                    }
                }
            })
            .store(in: &cancellables)
    }
}
