//
//  Data.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: String {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return String(describing: self)
        }
        return prettyString
    }
}
