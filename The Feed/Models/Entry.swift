//
//  Entry.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

protocol Content {
    var id: String { get }
    var updatedAt: Date { get }
    var createdAt: Date { get }
}

/**
 Contains all possible types of content, with enum cases for each.
 // TODO: @dgattey implement rest: these depend on sys.contentType.sys.id - if textBlock, we have slug and content, each with en-us entries inside, with content, for example. if location we have initialZoom, slug, image, point, zoomLevels. if project we have layout, thumbnail, creationDate, title, link, type, description. if book, we have coverImage, author, title, readDate, description. sys has updatedAt, createdAt, and type too

 */
enum Entry: Codable, Identifiable {
    case book(Book)
    case unknown
    
    var id: String {
        switch (self) {
            case .book(let book): return book.id
            case .unknown: return "unknown"
        }
    }
    
    static var dateFormatter: ISO8601DateFormatter {
        let isoFormatter = ISO8601DateFormatter()
        // Configure the formatter to handle fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter
    }
    
    enum CodingKeys: String, CodingKey {
        case sys
    }
    
    enum SysCodingKeys: String, CodingKey {
        case contentType
        case id
    }
    
    enum ContentTypeCodingKeys: String, CodingKey {
        case sys
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sysContainer = try container.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys)
        let contentTypeContainer = try sysContainer.nestedContainer(keyedBy: ContentTypeCodingKeys.self, forKey: .contentType)
        let sysContentTypeContainer = try contentTypeContainer.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys)
        let type = try sysContentTypeContainer.decode(String.self, forKey: .id)

        switch type {
        case "book":
            let book = try Book(from: decoder)
            self = .book(book)
        default:
            self = .unknown
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .book(let book):
            try container.encode(book)
        case .unknown:
            return
        }
    }
    
}
