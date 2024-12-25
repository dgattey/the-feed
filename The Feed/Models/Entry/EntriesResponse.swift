//
//  EntriesResponse.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import Foundation

/**
 The network response for Entries has "items" for entries.
 */
struct EntriesResponse: Codable {
    let items: [Entry]
    let limit: Int
    let total: Int
    let skip: Int
    
    enum CodingKeys: String, CodingKey, Hashable {
        case items
        case limit
        case total
        case skip
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        limit = try container.decode(Int.self, forKey: .limit)
        total = try container.decode(Int.self, forKey: .total)
        skip = try container.decode(Int.self, forKey: .skip)
        
        var itemsArray: [Entry] = []
        var ignoredTypes = Set<String>()
        
        // Decode the array of entries
        var entriesContainer = try container.nestedUnkeyedContainer(forKey: .items)
        
        // Iterate through each entry and attempt to decode it, letting non-unknown types error
        while !entriesContainer.isAtEnd {
            do {
                let entry = try entriesContainer.decode(Entry.self)
                itemsArray.append(entry)
            } catch let error as EntryTypeIgnoredError {
                ignoredTypes.insert(error.ignoredType)
                _ = try? entriesContainer.decode(EmptyDecodable.self)
                continue
            }
        }
        if(ignoredTypes.count > 0) {
            print ("Ignored \(ignoredTypes.count) entry types when decoding network response: \(ignoredTypes)")
        }
        
        self.items = itemsArray
    }
}
