//
//  ModelProtocols.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/28/24.
//

import Foundation

/**
 Every model should implement this at minimum
 */
protocol Model: Codable & Hashable & Equatable {}

/**
 Every model that can be client-side searched with a search string should implement this
 */
protocol SearchableModel: Model {
    func contains(searchText: String) -> Bool
}

/**
 Every model that can be identified with an id should implement this
 */
protocol IdentifiableModel: Model & Identifiable {}

/**
 This model protocol should be implemented by every top level Contentful model that has sys content and updated/created dates.
 */
protocol ContentfulModel: SearchableModel & IdentifiableModel {
    var sysContent: SysContent { get }
}

/**
 This should be used for models that can be created with defaults/no values
 */
protocol EmptyCreatableModel: Model {    
    init()
}

/**
 Empty so we can skip entries in a decoding setting if we don't want to error but we don't care about them
 */
struct EmptyModel: EmptyCreatableModel {
    init() {}
}
