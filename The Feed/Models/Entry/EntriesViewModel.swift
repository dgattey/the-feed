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
    
    func fetchData() async {
        DispatchQueue.main.sync {
            isLoading = true
        }
        
        // Create a promise to handle the async operation
        let result: Result<Entries, NetworkError> = await withCheckedContinuation { continuation in
            guard let publisher = ContentfulClient.getDataTaskPublisher(forType: .entries) else {
                continuation.resume(returning: .failure(.invalidResponse))
                return
            }
            
            publisher
                .decode(type: Entries.self, decoder: JSONDecoder())
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
        case .success(let entries):
            DispatchQueue.main.sync {
                self.isLoading = false
                self.entries = entries.items.filter { entry in
                    switch entry {
                    case .unknown:
                        return false
                    default:
                        return true
                    }
                }
            }
        case .failure(let error):
            DispatchQueue.main.sync {
                self.isLoading = false
                self.error = error.localizedDescription
            }
        }
    }
}
