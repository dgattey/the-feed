//
//  Entry.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

struct EntryResponse: Codable {
    let items: [Entry]
}

struct Entry: Codable {
    let fields: EntryFields
    let metadata: EntryMetadata
    let sys: EntrySys
}

struct EntryFields: Codable {
//    let title: String
//    let body: String
}

struct EntryMetadata: Codable {
    let tags: [EntryTag]
}

struct EntryTag: Codable {
    let name: String
    let slug: String
}

struct EntrySys: Codable {
    let id: String
    let type: String
    let contentType: EntryContentType
    let createdAt: EntryDate
    let updatedAt: EntryDate
}

struct EntryContentType: Codable {
    let id: String?
    let linkType: String?
}

class EntryDate: Codable {
    let value: Date
    
    required init(from decoder: any Decoder) throws {
        let stringDate = try decoder.singleValueContainer().decode(String.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        value = dateFormatter.date(from: stringDate)!
    }
}

