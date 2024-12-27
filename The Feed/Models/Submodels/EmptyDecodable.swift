//
//  EmptyDecodable.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/24/24.
//

/**
 Empty so we can skip entries in a decoding setting if we don't want to error but we don't care about them
 */
struct EmptyDecodable: Decodable {}