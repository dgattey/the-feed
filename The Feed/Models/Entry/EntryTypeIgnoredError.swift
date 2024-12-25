//
//  EntryTypeIgnoredError.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/24/24.
//

struct EntryTypeIgnoredError: Error {
    let description: String = "Entry type ignored."
    let ignoredType: String
}
