//
//  Entry.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

/**
 Contains all possible types of content, with enum cases for each. This _would_ be a `ContentfulModel`, but this is basically just a wrapper model that has inside it an actual `ContentfulModel`
 */
enum Entry: SearchableModel & IdentifiableModel {
    case book(Book)
    case location(Location)
    case textBlock(TextBlock)
    
    var id: String {
        switch self {
        case .book(let book): return book.id
        case .location(let location): return location.id
        case .textBlock(let textBlock): return textBlock.id
        }
    }
    
    var category: GroupedEntriesCategory {
        switch self {
        case .book: return .book
        case .location: return .location
        case .textBlock: return .textBlock
        }
    }
    
    func contains(searchText: String, withCategories categories: [GroupedEntriesCategory]) -> Bool {
        if (categories.count > 0 && !categories.contains(category)) {
            return false
        }
        return contains(searchText: searchText)
    }
    
    func contains(searchText: String) -> Bool {
        switch (self) {
        case .book(let book): return book.contains(searchText: searchText)
        case .location(let location): return location.contains(searchText: searchText)
        case .textBlock(let textBlock): return textBlock.contains(searchText: searchText)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case sys
        case fields
    }
    
    enum SysCodingKeys: String, CodingKey {
        case contentType
        case id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sysContainer = try container.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys)
        let contentTypeContainer = try sysContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .contentType)
        let sysContentTypeContainer = try contentTypeContainer.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys)
        let type = try sysContentTypeContainer.decode(String.self, forKey: .id)

        switch type {
        case "book":
            let book = try Book(from: decoder)
            self = .book(book)
        case "location":
            let location = try Location(from: decoder)
            self = .location(location)
        case "textBlock":
            let textBlock = try TextBlock(from: decoder)
            self = .textBlock(textBlock)
        default:
            throw EntryTypeIgnoredError(ignoredType: type)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .book(let book):
            try container.encode(book)
        case .location(let location):
            try container.encode(location)
        case .textBlock(let textBlock):
            try container.encode(textBlock)
        }
    }
    
}
