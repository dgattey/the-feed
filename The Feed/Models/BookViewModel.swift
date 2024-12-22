//
//  BookViewModel.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

class BookViewModel: ObservableObject {
    @Published var book = [Book]()
    
    init(book: [Book] = []) {
        self.book = book
    }
    
    func fetchData() -> URL? {
        guard let route = getApiRoute(forType: .Book),
              let url = URL(string: route) else {
            print("Error constructing URL for books")
            return nil
        }
        print(url.absoluteString)
        return url
    }
        
}
