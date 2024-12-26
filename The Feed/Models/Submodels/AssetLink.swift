//
//  AssetLink.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/26/24.
//

/**
 There are links to assets, like from the `coverImage` of a `Book` or related. It's just a stub to the actual content, which is not yet loaded as this item is used.
 */
struct AssetLink: Codable, Hashable {
    let assetId: String
    
    enum CodingKeys: String, CodingKey {
        case sys
    }
    
    enum SysKeys: String, CodingKey {
        case id
        case linkType
        case type
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let sysContainer = try container.nestedContainer(keyedBy: SysKeys.self, forKey: .sys)
        assetId = try sysContainer.decode(String.self, forKey: .id)
        
        // For sanity, we confirm that linkType and type are right, otherwise we error
        let linkType = try sysContainer.decode(String.self, forKey: .linkType)
        let type = try sysContainer.decode(String.self, forKey: .type)
        guard linkType == "Asset" && type == "Link" else {
            throw DecodingError
                .typeMismatch(
                    AssetLink.self,
                    DecodingError.Context(
                        codingPath: sysContainer.codingPath,
                        debugDescription: "Link type or type for asset \(assetId) is wrong")
                )
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var sysContainer = container.nestedContainer(keyedBy: SysKeys.self, forKey: .sys)
        try sysContainer.encode(assetId, forKey: .id)
        
        try sysContainer.encode("Asset", forKey: .linkType)
        try sysContainer.encode("Link", forKey: .type)
    }
}
