//
//  ViewModel.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/28/24.
//

import Foundation
import Combine
import SwiftUI

/**
 Class to handle some shared things about view models automatically
 */
class ViewModel: ObservableObject {
    @Published var isLoading = false
    private var errorsViewModel: ErrorsViewModel
    
    init(_ errorsViewModel: ErrorsViewModel) {
        self.errorsViewModel = errorsViewModel
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    /**
     Call to handle any network error and update the models with it
     */
    private func handleError(_ error: NetworkError) {
        self.isLoading = false
        self.errorsViewModel.add(error)
        if (_isDebugAssertConfiguration()) {
            print("Hit error: \(error)")
        }
    }
    
    /**
     Fetches data with error handling and decoding built in via generics
     */
    func fetchData<ResponseType: EmptyCreatableModel>(
        _ publisher:  AnyPublisher<DataSource<Data>, any Error>?,
        receiveValue: @escaping (DataSource<ResponseType>) -> Void
    ) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        guard let publisher = publisher else {
            DispatchQueue.main.async {
                self.handleError(.invalidResponse)
            }
            return
        }
        
        publisher
            .tryMap { dataSource -> DataSource<ResponseType> in
                let data = dataSource.value
                if ResponseType.self == JustDataResponse.self {
                    // No decoding necessary
                    return DataSource<ResponseType>(
                        value: JustDataResponse(data) as! ResponseType,
                        origin: dataSource.origin
                    )
                }
                
                let decoder = JSONDecoder()
                decoder
                    .userInfo[JSONDecoder.contextKey] = DecodingContext(
                        errorsViewModel: self.errorsViewModel,
                        dataOrigin: dataSource.origin
                    )
                do {
                    let response = try decoder.decode(ResponseType.self, from: data)
                    
                    // Wrap it back up for later use
                    return DataSource<ResponseType>(
                        value: response,
                        origin: dataSource.origin
                    )
                } catch {
                    if (dataSource.origin == .cache) {
                        // Empty data if we have a problem with cached data
                        return DataSource<ResponseType>(
                            value: ResponseType(),
                            origin: .cache
                        )
                    }
                    throw error
                }
            }
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return NetworkError.decodingError(decodingError)
                }
                if (_isDebugAssertConfiguration()) {
                    print("Map error - \(error)")
                }
                return NetworkError.invalidResponse
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.handleError(error)
                }
            }, receiveValue: receiveValue)
            .store(in: &cancellables)
    }
}
