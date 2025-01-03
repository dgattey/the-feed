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
        if category.contains(searchText: searchText) {
            return true
        }
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
        guard let context = decoder.userInfo[JSONDecoder.contextKey] as? DecodingContext else {
            throw DecodingError
                .dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Missing JSONDecoder.contextKey \(decoder.userInfo)")
                )
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sysContainer = try container.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys)
        let contentTypeContainer = try sysContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .contentType)
        let sysContentTypeContainer = try contentTypeContainer.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys)
        let type = try sysContentTypeContainer.decode(String.self, forKey: .id)

        switch type {
        case "book":
            do {
                let book = try Book(from: decoder)
                self = .book(book)
            } catch let error as LocalizedError {
                do {
                    let book = try Book(withSysContentFrom: decoder)
                    self = .book(book)
                    if (context.dataOrigin == .network) {
                        context.errorsViewModel.add(error)
                    }
                } catch let error as LocalizedError {
                    self = .book(Book())
                    if (context.dataOrigin == .network) {
                        context.errorsViewModel.add(error)
                    }
                }
            }
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

/**
 Adds some grouping/sorting/filtering to arrays of entries
 */
extension [Entry] {
    /**
     Applies a sort to the list, using dates if available, otherwise ids and such
     */
    var sorted: [Entry] {
        self.sorted { e1, e2 in
            switch (e1, e2) {
            case (.book(let b1), .book(let b2)):
                let b1Date: Date? = b1.readDateFinished ?? b1.readDateStarted ?? b1.sysContent.createdAt
                let b2Date: Date? = b2.readDateFinished ?? b2.readDateStarted ?? b2.sysContent.createdAt
                if let b1Date = b1Date, let b2Date = b2Date {
                    return b1Date > b2Date
                }
                return b1.id < b2.id
            case (.location(let l1), .location(let l2)):
                return l1.slug < l2.slug
            default:
                return e1.id < e2.id
            }
        }
    }
    
    /**
     Applies category filters to the list
     */
    func filtered(
        byCategories categories: Set<GroupedEntriesCategory>,
        searchText: String?
    ) -> [Entry] {
        let filteredByCategories = self.filter { entry in
            switch entry {
            case .book:
                return categories.contains(.book)
            case .location:
                return categories.contains(.location)
            case .textBlock:
                return categories.contains(.textBlock)
            }
        }
        
        // Apply search text filter
        if let searchText, !searchText.isEmpty {
            return filteredByCategories
                .filter { $0.contains(searchText: searchText) }
        }
        return filteredByCategories
    }
}
