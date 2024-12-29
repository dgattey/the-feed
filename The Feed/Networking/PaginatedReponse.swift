//
//  PaginatedReponse.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/28/24.
//

/**
 The network response has limit, total, and skip. This should be subclassed and all four functions reimplemented.
 */
class PaginatedResponse: EmptyCreatableModel {
    let limit: Int
    let total: Int
    let skip: Int
    
    enum CodingKeys: String, CodingKey, Model {
        case limit
        case total
        case skip
    }
    
    /**
     Blank content for use when erroring and needing a fallback
     */
    required init() {
        limit = 0
        total = 0
        skip = 0
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        limit = try container.decode(Int.self, forKey: .limit)
        total = try container.decode(Int.self, forKey: .total)
        skip = try container.decode(Int.self, forKey: .skip)
    }
    
    static func == (lhs: PaginatedResponse, rhs: PaginatedResponse) -> Bool {
        return lhs.limit == rhs.limit && lhs.total == rhs.total && lhs.skip == rhs.skip
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(limit)
        hasher.combine(total)
        hasher.combine(skip)
    }
}
