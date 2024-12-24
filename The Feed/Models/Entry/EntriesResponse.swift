//
//  EntriesResponse.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

/**
 The network response for Entries has "items" for entries.
 */
struct EntriesResponse: Codable {
    let items: [Entry]
}
