//
//  AssetLink.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/26/24.
//

import Foundation

/**
 There are links to assets, like from the `coverImage` of a `Book` or related. It's just a stub to the actual content, which is not yet loaded as this item is used.
 */
struct AssetLink: ContentfulModel & EmptyCreatableModel {
    let sysContent: SysContent
    
    var id: String {
        return sysContent.id
    }
    
    enum CodingKeys: String, CodingKey {
        case sys
    }
    
    init() {
        sysContent = SysContent(id: "")
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        sysContent = try SysContent(from: decoder)
        
        // For sanity, we confirm that linkType and type are right, otherwise we error
        guard sysContent.linkType == "Asset" && sysContent.type == "Link" else {
            throw DecodingError
                .typeMismatch(
                    AssetLink.self,
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Link type or type for asset \(sysContent.id) is wrong")
                )
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        try sysContent.encode(to: encoder)
    }
    
    func contains(searchText: String) -> Bool {
        sysContent.contains(searchText: searchText)
    }
}
