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
    func prettyPrintJSON() {
        guard let object = try? JSONSerialization.jsonObject(with: self) else {
            print("Could not create JSON object from data")
            return
        }
        
        guard let serializedData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]) else {
            print("Could not serialize JSON data")
            return
        }
        
        if let prettyJSONString = String(data: serializedData, encoding: .utf8) {
            print(prettyJSONString)
        }
    }
}
