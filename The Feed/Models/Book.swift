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
struct Book: ConcreteEntry {
    let sysContent: SysContent
    let title: String
    let author: String
    let readDate: Date
    let description: TextNode
    // TODO: @dgattey handle coverImage
    
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
    
    func contains(searchText: String) -> Bool {
        return title.localizedCaseInsensitiveContains(searchText) || author.localizedCaseInsensitiveContains(searchText)
    }
    
    enum FieldsCodingKeys: String, CodingKey {
        case title
        case author
        case readDate
        case description
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Entry.CodingKeys.self)
        sysContent = try SysContent(from: decoder)
        
        let fieldsContainer = try container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        let titleContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .title)
        title = try titleContainer.decode(String.self, forKey: .locale)
        
        let authorContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .author)
        author = try authorContainer.decode(String.self, forKey: .locale)
        
        let readDateContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .readDate)
        let readDateString = try readDateContainer.decode(String.self, forKey: .locale)
        readDate = Book.dateFormatter.date(from: readDateString)!
        
        let descriptionContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .description)
        description = try descriptionContainer.decode(TextNode.self, forKey: .locale)
        
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Entry.CodingKeys.self)
        try sysContent.encode(to: encoder)
        
        var fieldsContainer = container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        var titleContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .title)
        try titleContainer.encode(title, forKey: .locale)
        
        var authorContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .author)
        try authorContainer.encode(author, forKey: .locale)
        
        var readDateContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .readDate)
        let readDateString = Book.dateFormatter.string(from: readDate)
        try readDateContainer.encode(readDateString, forKey: .locale)
    }
}
