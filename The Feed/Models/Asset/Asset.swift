//
//  AssetResponse.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/28/24.
//

import Foundation

/**
 A Contentful-powered asset model for a full Asset from Contentful
 */
class Asset: ContentfulModel & EmptyCreatableModel & ObservableObject {
    let sysContent: SysContent
    let description: String
    let file: AssetFile
    let title: String
    
    var id: String {
        return sysContent.id
    }
    
    func contains(searchText: String) -> Bool {
        return sysContent.contains(searchText: searchText)
        || description.localizedCaseInsensitiveContains(searchText)
        || file.contains(searchText: searchText)
        || title.localizedCaseInsensitiveContains(searchText)
    }
    
    enum FieldsCodingKeys: String, CodingKey {
        case description
        case file
        case title
    }
    
    required init() {
        sysContent = SysContent()
        description = ""
        file = AssetFile()
        title = ""
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Entry.CodingKeys.self)
        sysContent = try SysContent(from: decoder)
        
        let fieldsContainer = try container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        let descriptionContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .description)
        description = try descriptionContainer.decode(String.self, forKey: .locale)
        
        let fileContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .file)
        file = try fileContainer.decode(AssetFile.self, forKey: .locale)
        
        let titleContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .title)
        title = try titleContainer.decode(String.self, forKey: .locale)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Entry.CodingKeys.self)
        try sysContent.encode(to: encoder)
        
        var fieldsContainer = container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        var descriptionContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .description)
        try descriptionContainer.encode(description, forKey: .locale)
        
        var fileContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .file)
        try fileContainer.encode(file, forKey: .locale)
        
        var titleContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .title)
        try titleContainer.encode(title, forKey: .locale)
    }
    
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.sysContent == rhs.sysContent
        && lhs.description == rhs.description
        && lhs.file == rhs.file
        && lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sysContent)
        hasher.combine(description)
        hasher.combine(file)
        hasher.combine(title)
    }
}

struct AssetFile: EmptyCreatableModel & SearchableModel {
    let contentType: String
    let fileName: String
    let url: String
    
    init() {
        contentType = ""
        fileName = ""
        url = ""
    }
    
    func contains(searchText: String) -> Bool {
        return contentType.localizedCaseInsensitiveContains(searchText)
        || fileName.localizedCaseInsensitiveContains(searchText)
        || url.localizedCaseInsensitiveContains(searchText)
    }
}
