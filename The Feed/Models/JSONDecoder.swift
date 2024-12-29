//
//  JSONDecoder.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/29/24.
//

import Foundation

struct DecodingContext {
    let errorsViewModel: ErrorsViewModel
}

extension JSONDecoder {
    static let contextKey = CodingUserInfoKey(rawValue: "contextKey")!
    
    var context: DecodingContext? {
        get { userInfo[JSONDecoder.contextKey] as? DecodingContext }
        set { userInfo[JSONDecoder.contextKey] = newValue }
    }
}
