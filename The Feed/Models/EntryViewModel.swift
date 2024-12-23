//
//  EntryViewModel.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

class EntryViewModel: ObservableObject {
    @Published var entry = [Entry]()
    
    init(entry: [Entry] = []) {
        self.entry = entry
    }
    
    func fetchData() {
        runDataTask(forType: .entries, httpMethod: .get) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let decoder = JSONDecoder()
            if let safeData = data {
                do {
                    let results = try decoder.decode(EntryResponse.self, from: safeData)
                    DispatchQueue.main.async {
                        self.entry = results.items
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
        
}
