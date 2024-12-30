//
//  Entries.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import Foundation

/**
 Contains a list of entries that are decoded one by one and any invalid ones are skipped.
 */
class Entries: PaginatedResponse {
    let items: [Entry]
    
    enum CodingKeys: String, CodingKey, Model {
        case items
    }
    
    /**
     Blank content for use when erroring and needing a fallback
     */
    required init() {
        items = []
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[JSONDecoder.contextKey] as? DecodingContext else {
            throw DecodingError
                .dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Missing JSONDecoder.contextKey \(decoder.userInfo)")
                )
        }
            
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
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
                _ = try? entriesContainer.decode(EmptyModel.self)
                continue
            } catch let error as LocalizedError {
                if (context.dataOrigin == .network) {
                    context.errorsViewModel.add(error)
                }
                _ = try? entriesContainer.decode(EmptyModel.self)
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
        try super.init(from: decoder)
    }
    
    static func == (lhs: Entries, rhs: Entries) -> Bool {
        let paginatedEqual = lhs.limit == rhs.limit && lhs.total == rhs.total && lhs.skip == rhs.skip
        return paginatedEqual && lhs.items == rhs.items
    }
    
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(items)
    }
}
