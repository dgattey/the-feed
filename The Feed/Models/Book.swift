//
//  Book.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

/**
 A Contentful-powered book model, with reformatted data for ease of use when working with it locally
 */
struct Book: Content {
    let sysContent: SysContent
    let title: String
    let author: String
    let readDate: Date
    
    var id: String {
        return sysContent.id
    }
    
    var updatedAt: Date {
        return sysContent.updatedAt
    }
    
    var createdAt: Date {
        return sysContent.createdAt
    }
    
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    enum CodingKeys: String, CodingKey {
        case sys
        case fields
    }
    
    enum FieldsCodingKeys: String, CodingKey {
        case title
        case author
        case readDate
    }
    
    enum TitleCodingKeys: String, CodingKey {
        case locale = "en-US"
    }
    
    enum AuthorCodingKeys: String, CodingKey {
        case locale = "en-US"
    }
    
    enum ReadDateCodingKeys: String, CodingKey {
        case locale = "en-US"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sysContent = try SysContent(from: decoder)
        
        let fieldsContainer = try container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        let titleContainer = try fieldsContainer.nestedContainer(keyedBy: TitleCodingKeys.self, forKey: .title)
        title = try titleContainer.decode(String.self, forKey: .locale)
        
        let authorContainer = try fieldsContainer.nestedContainer(keyedBy: AuthorCodingKeys.self, forKey: .author)
        author = try authorContainer.decode(String.self, forKey: .locale)
        
        let readDateContainer = try fieldsContainer.nestedContainer(keyedBy: ReadDateCodingKeys.self, forKey: .readDate)
        let readDateString = try readDateContainer.decode(String.self, forKey: .locale)
        readDate = Book.dateFormatter.date(from: readDateString)!
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try sysContent.encode(to: encoder)
        
        var fieldsContainer = container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        var titleContainer = fieldsContainer.nestedContainer(keyedBy: TitleCodingKeys.self, forKey: .title)
        try titleContainer.encode(title, forKey: .locale)
        
        var authorContainer = fieldsContainer.nestedContainer(keyedBy: AuthorCodingKeys.self, forKey: .author)
        try authorContainer.encode(author, forKey: .locale)
        
        var readDateContainer = fieldsContainer.nestedContainer(keyedBy: ReadDateCodingKeys.self, forKey: .readDate)
        let readDateString = Book.dateFormatter.string(from: readDate)
        try readDateContainer.encode(readDateString, forKey: .locale)
    }
}
