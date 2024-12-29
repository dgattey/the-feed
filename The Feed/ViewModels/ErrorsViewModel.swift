//
//  ErrorsViewModel.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/28/24.
//

import SwiftUI
import Combine

class ErrorsViewModel: ObservableObject {
    @Published private(set) var errors: Set<String> = []
    @Published private(set) var hasErrors = false
    
    var errorCount: Int { errors.count }
    
    func add(_ error: LocalizedError) {
        DispatchQueue.main.async {
            print(error)
            self.hasErrors = true
            self.errors.insert(error.localizedDescription)
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.hasErrors = false
            self.errors.removeAll()
        }
    }
}
