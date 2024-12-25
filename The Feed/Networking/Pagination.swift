//
//  Pagination.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/24/24.
//

/**
 Encapsulates pagination args for the API calls
 */
struct Pagination {
    private static let defaultLimit = 100
    
    let limit: Int
    let skip: Int
    
    init(limit: Int = Pagination.defaultLimit, skip: Int = 0) {
        self.limit = limit
        self.skip = skip
    }
    
    func next() -> Pagination {
        return Pagination(limit: limit, skip: skip + limit)
    }
    
    static let `default`: Pagination = .init(limit: defaultLimit, skip: 0)
}
