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
struct EntriesResponse: Codable, Hashable {
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
    
    /**
     Blank content for use when erroring and needing a fallback
     */
    init() {
        items = []
        limit = 0
        total = 0
        skip = 0
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
        let entryCount = entriesContainer.count ?? 0
        var ignoredCount = 0
        
        // Iterate through each entry and attempt to decode it, letting non-unknown types error
        while !entriesContainer.isAtEnd {
            do {
                let entry = try entriesContainer.decode(Entry.self)
                itemsArray.append(entry)
            } catch let error as EntryTypeIgnoredError {
                ignoredTypes.insert(error.ignoredType)
                ignoredCount += 1
                _ = try? entriesContainer.decode(EmptyDecodable.self)
                continue
            }
        }
        
        // Print out how many we ignored and what the distinct types were
        if(ignoredTypes.count > 0 && _isDebugAssertConfiguration()) {
            print(
                "Ignored \(ignoredCount)/\(entryCount) entries (\(ignoredTypes.count) distinct entry types: \(ignoredTypes.joined(separator: ", ")))"
            )
        }
        
        self.items = itemsArray
    }
}
