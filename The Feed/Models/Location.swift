//
//  Location.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import Foundation

/**
 A Contentful-powered location model, with reformatted data for ease of use when working with it locally
 */
struct Location: ConcreteEntry {
    let sysContent: SysContent
    let initialZoom: Double
    let slug: String
    let point: LatLong
    let zoomLevels: [String]
    // TODO: @dgattey handle image
    
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
    }
    
    enum FieldsCodingKeys: String, CodingKey {
        case initialZoom
        case slug
        case point
        case zoomLevels
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Entry.CodingKeys.self)
        sysContent = try SysContent(from: decoder)
        
        let fieldsContainer = try container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        let initialZoomContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .initialZoom)
        initialZoom = try initialZoomContainer.decode(Double.self, forKey: .locale)
        
        let slugContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .slug)
        slug = try slugContainer.decode(String.self, forKey: .locale)
        
        let pointContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .point)
        point = try pointContainer.decode(LatLong.self, forKey: .locale)
        
        let zoomLevelsContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .zoomLevels)
        zoomLevels = try zoomLevelsContainer.decode([String].self, forKey: .locale)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Entry.CodingKeys.self)
        try sysContent.encode(to: encoder)
        
        var fieldsContainer = container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        var initialZoomContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .initialZoom)
        try initialZoomContainer.encode(initialZoom, forKey: .locale)
        
        var slugContainer = fieldsContainer.nestedContainer(
            keyedBy: FieldItemCodingKeys.self,
            forKey: .slug
        )
        try slugContainer.encode(slug, forKey: .locale)
        
        var pointContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .point)
        try pointContainer.encode(point, forKey: .locale)
        
        var zoomLevelsContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .zoomLevels)
        try zoomLevelsContainer.encode(zoomLevels, forKey: .locale)
    }
}
