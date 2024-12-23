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
struct Location: Content {
    let sysContent: SysContent
    let initialZoom: Float
    let slug: String
    // TODO: @dgattey handle these too
    //    let image: String
    //    let point: LatLong
    //    let zoomLevels: [Float]
    
    var id: String {
        return sysContent.id
    }
    
    var updatedAt: Date {
        return sysContent.updatedAt
    }
    
    var createdAt: Date {
        return sysContent.createdAt
    }
    
    enum FieldsCodingKeys: String, CodingKey {
        case initialZoom
        case slug
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Entry.CodingKeys.self)
        sysContent = try SysContent(from: decoder)
        
        let fieldsContainer = try container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        let initialZoomContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .initialZoom)
        initialZoom = try initialZoomContainer.decode(Float.self, forKey: .locale)
        
        let slugContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .slug)
        slug = try slugContainer.decode(String.self, forKey: .locale)
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
    }
}
