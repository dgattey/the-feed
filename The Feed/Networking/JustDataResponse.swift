//
//  JustDataResponse.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/28/24.
//

import Foundation

/**
 This is a response that is itself just Data and not JSON representable
 */
class JustDataResponse: EmptyCreatableModel {
    let data: Data
    
    init(_ data: Data) {
        self.data = data
    }
    
    required init() {
        data = Data()
    }
    
    required init(from decoder: any Decoder) throws {
        data = Data()
    }
    
    static func == (lhs: JustDataResponse, rhs: JustDataResponse) -> Bool {
        return lhs.data == rhs.data
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
    
}
