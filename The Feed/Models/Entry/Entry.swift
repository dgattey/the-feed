//
//  Entry.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

/**
 An entry or entry wrapper that is searchable and identifiable
 */
protocol SearchableEntry: Codable, Identifiable, Hashable {
    var id: String { get }
    func contains(searchText: String) -> Bool
}

/**
 The `Entry` enum is a container type wrapping a concrete instance. Every concrete instance should implement this.
 */
protocol ConcreteEntry: SearchableEntry {
    var updatedAt: Date { get }
    var createdAt: Date { get }
    var sysContent: SysContent { get }
}

/**
 Contains all possible types of content, with enum cases for each.
 // TODO: @dgattey implement rest: these depend on sys.contentType.sys.id - if textBlock, we have slug and content, each with en-us entries inside, with content, for example. if location we have initialZoom, slug, image, point, zoomLevels. if project we have layout, thumbnail, creationDate, title, link, type, description.

 */
enum Entry: SearchableEntry {
    case book(Book)
    case location(Location)
    case unknown
    
    var id: String {
        switch (self) {
        case .book(let book): return book.id
        case .location(let location): return location.id
        case .unknown: return "unknown"
        }
    }
    
    func contains(searchText: String) -> Bool {
        switch (self) {
        case .book(let book): return book.contains(searchText: searchText)
        case .location(let location): return location.contains(searchText: searchText)
        case .unknown: return false
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
        default:
            self = .unknown
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .book(let book):
            try container.encode(book)
        case .location(let location):
            try container.encode(location)
        case .unknown:
            return
        }
    }
    
}
