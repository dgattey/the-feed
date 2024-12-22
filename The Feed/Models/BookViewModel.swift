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
    
    func fetchData() {
        guard let url = URL(string: )
    }
        
}
