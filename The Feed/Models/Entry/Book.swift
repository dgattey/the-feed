//
//  Book.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/22/24.
//

import Foundation

/**
 A Contentful-powered book model, with reformatted data for ease of use when working with it locally
 */
struct Book: ContentfulModel & EmptyCreatableModel {
    let sysContent: SysContent
    let title: String
    let author: String
    let isbn: Int?
    let readDateStarted: Date?
    let readDateFinished: Date?
    let reviewDescription: TextNode?
    let coverImage: AssetLink
    let rating: Int?
    
    var id: String {
        return sysContent.id
    }
    
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    func contains(searchText: String) -> Bool {
        return title.localizedCaseInsensitiveContains(searchText)
        || author.localizedCaseInsensitiveContains(searchText)
        || String(describing: isbn).localizedCaseInsensitiveContains(searchText)
        || readDateStarted?.description.localizedCaseInsensitiveContains(searchText) ?? false
        || readDateFinished?.description.localizedCaseInsensitiveContains(searchText) ?? false
        || reviewDescription?.contains(searchText: searchText) ?? false
        || sysContent.contains(searchText: searchText)
        || String(describing: rating).localizedCaseInsensitiveContains(searchText)
    }
    
    enum FieldsCodingKeys: String, CodingKey {
        case title
        case author
        case isbn
        case readDateStarted
        case readDateFinished
        case reviewDescription
        case coverImage
        case rating
    }
    
    init() {
        self.init(sysContent: SysContent())
    }
    
    init(sysContent: SysContent) {
        self.title = "Unknown book"
        self.author = "Unknown author"
        self.sysContent = sysContent
        self.isbn = nil
        self.coverImage = AssetLink()
        self.rating = nil
        self.reviewDescription = nil
        self.readDateStarted = nil
        self.readDateFinished = nil
    }
    
    init(withSysContentFrom decoder: any Decoder) throws {
        let sysContent = try SysContent(from: decoder)
        self.init(sysContent: sysContent)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Entry.CodingKeys.self)
        sysContent = try SysContent(from: decoder)
        
        let fieldsContainer = try container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        let titleContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .title)
        title = try titleContainer.decode(String.self, forKey: .locale)
        
        let authorContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .author)
        author = try authorContainer.decode(String.self, forKey: .locale)
        
        let isbnContainer = try? fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .isbn)
        if let isbnContainer {
            isbn = try isbnContainer.decode(Int.self, forKey: .locale)
        } else {
            isbn = nil
        }
        
        let readDateFinishedContainer = try? fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .readDateFinished)
        if let readDateFinishedContainer {
            let readDateFinishedString = try readDateFinishedContainer.decode(String.self, forKey: .locale)
            readDateFinished = Book.dateFormatter.date(from: readDateFinishedString)!
        } else {
            readDateFinished = nil
        }
        
        
        let readDateStartedContainer = try? fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .readDateStarted)
        if let readDateStartedContainer {
            let readDateStartedString = try readDateStartedContainer.decode(String.self, forKey: .locale)
            readDateStarted = Book.dateFormatter.date(from: readDateStartedString)!
        } else {
            readDateStarted = nil
        }
        
        let reviewDescriptionContainer = try? fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .reviewDescription)
        if let reviewDescriptionContainer {
            reviewDescription = try reviewDescriptionContainer.decode(TextNode.self, forKey: .locale)
        } else {
            reviewDescription = nil
        }
        
        let coverImageContainer = try fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .coverImage)
        coverImage = try coverImageContainer.decode(AssetLink.self, forKey: .locale)
        
        let ratingContainer = try? fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .rating)
        if let ratingContainer {
            rating = try ratingContainer.decode(Int.self, forKey: .locale)
        } else {
            rating = nil
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Entry.CodingKeys.self)
        try sysContent.encode(to: encoder)
        
        var fieldsContainer = container.nestedContainer(keyedBy: FieldsCodingKeys.self, forKey: .fields)
        
        var titleContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .title)
        try titleContainer.encode(title, forKey: .locale)
        
        var authorContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .author)
        try authorContainer.encode(author, forKey: .locale)
        
        if let isbn = isbn {
            var isbnContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .isbn)
            try isbnContainer.encode(isbn, forKey: .locale)
        }
        
        if let readDateStarted = readDateStarted {
            var readDateStartedContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .readDateStarted)
            let readDateStartedString = Book.dateFormatter.string(from: readDateStarted)
            try readDateStartedContainer.encode(readDateStartedString, forKey: .locale)
        }
        
        if let readDateFinished = readDateFinished {
            var readDateFinishedContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .readDateFinished)
            let readDateFinishedString = Book.dateFormatter.string(from: readDateFinished)
            try readDateFinishedContainer.encode(readDateFinishedString, forKey: .locale)
        }
        
        var coverImageContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .coverImage)
        try coverImageContainer.encode(coverImage, forKey: .locale)
        
        if let reviewDescription = reviewDescription {
            var reviewDescriptionContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .reviewDescription)
            try reviewDescriptionContainer.encode(reviewDescription, forKey: .locale)
        }
        
        if let rating = rating {
            var ratingContainer = fieldsContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .rating)
            try ratingContainer.encode(rating, forKey: .locale)
        }
    }
}
