//
//  DataExtension.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/25/24.
//

import Foundation

extension Data {
    /**
     Allows for easier debugging!
     */
    func prettyJsonString() -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: self) else {
            return nil
        }
        
        guard let serializedData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]) else {
            return nil
        }
        
        return String(data: serializedData, encoding: .utf8)
    }
}
