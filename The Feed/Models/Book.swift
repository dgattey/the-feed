//
//  Book.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

struct BookResponse: Codable {
    let books: [Book]
}

struct Book: Codable {
    let title: String
    let author: String
    let coverImageUrl: String
    let readDate: Date
    let description: String
}
