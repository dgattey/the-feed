//
//  EntriesViewModel.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

class EntriesViewModel: ObservableObject {
    @Published var entries = [Entry]()
    @Published var error: NetworkError?
    @Published var isLoading: Bool = false
    
    struct EntriesResponse: Codable {
        let items: [Entry]
    }
    
    init(entries: [Entry] = []) {
        self.entries = entries
    }
    
    func fetchData() -> Void {
        self.isLoading = true
        ContentfulClient.fetchData(forType: .entries) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(EntriesResponse.self, from: data)
                    let entries = results.items.filter({ entry in
                        switch (entry) {
                        case .unknown: return false
                        default: return true
                        }
                    })
                    DispatchQueue.main.async {
                        self.entries = entries
                        self.isLoading = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(data.prettyPrintedJSONString)
                        self.error = .unexpectedError(error)
                        self.isLoading = false
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
        
}
