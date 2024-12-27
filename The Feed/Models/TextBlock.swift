//
//  TextBlock.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/26/24.
//

import Foundation

/**
 A Contentful-powered TextBlock model, with reformatted data for ease of use when working with it locally
 */
struct TextBlock: ConcreteEntry {
    let sysContent: SysContent
    let title: String
    let slug: String
    let content: TextNode
    
    var id: String {
        return sysContent.id
    }
    
    var updatedAt: Date {
        return sysContent.updatedAt
    }
    
    var createdAt: Date {
        return sysContent.createdAt
    }
    
    func contains(searchText: String) -> Bool {
        return slug.localizedCaseInsensitiveContains(searchText)
        || content.contains(searchText: searchText)
        || sysContent.contains(searchText: searchText)
        || title.localizedCaseInsensitiveContains(searchText)
    }
    
    enum FieldsCodingKeys: String, CodingKey {
        case title
        case slug
        case content
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Entry.CodingKeys.self)
        sysContent = try SysContent(from: decoder)
        
        let fieldsContainer = try container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        let titleContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .title)
        title = try titleContainer.decode(String.self, forKey: .locale)
        
        let slugContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .slug)
        slug = try slugContainer.decode(String.self, forKey: .locale)
        
        let contentContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .content)
        content = try contentContainer.decode(TextNode.self, forKey: .locale)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Entry.CodingKeys.self)
        try sysContent.encode(to: encoder)
        
        var fieldsContainer = container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        var titleContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .title)
        try titleContainer.encode(title, forKey: .locale)
        
        var slugContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .slug)
        try slugContainer.encode(slug, forKey: .locale)
        
        var contentContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .content)
        try contentContainer.encode(content, forKey: .locale)
    }
}
