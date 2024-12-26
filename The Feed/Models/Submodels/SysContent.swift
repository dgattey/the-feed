//
//  SysContent.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import Foundation

struct SysContent: Codable, Hashable, SearchableEntry {
    let id: String
    let updatedAt: Date
    let createdAt: Date
    let fieldStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case sys
    }
    
    enum SysCodingKeys: String, CodingKey {
        case id
        case updatedAt
        case createdAt
        case fieldStatus
    }
    
    enum FieldStatusKeys: String, CodingKey {
        case all = "*"
    }
    
    static var dateFormatter: ISO8601DateFormatter {
        let isoFormatter = ISO8601DateFormatter()
        // Configure the formatter to handle fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sysContainer = try container.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys)
        id = try sysContainer.decode(String.self, forKey: .id)
        let updatedAtString = try sysContainer.decode(String.self, forKey: .updatedAt)
        updatedAt = SysContent.dateFormatter.date(from: updatedAtString)!
        let createdAtString = try sysContainer.decode(String.self, forKey: .createdAt)
        createdAt = SysContent.dateFormatter.date(from: createdAtString)!
        
        let fieldStatusContainerOrNil = try? sysContainer.nestedContainer(keyedBy: FieldStatusKeys.self, forKey: .fieldStatus)
        if let fieldStatusContainer = fieldStatusContainerOrNil {
            let allFieldStatusContainer = try fieldStatusContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .all)
            fieldStatus = try allFieldStatusContainer.decode(String.self, forKey: .locale)
        } else {
            fieldStatus = nil
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var sysContainer = container.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys)
        try sysContainer.encode(id, forKey: .id)
        try sysContainer.encode(updatedAt, forKey: .updatedAt)
        try sysContainer.encode(createdAt, forKey: .createdAt)
        
        if let fieldStatus = self.fieldStatus {
            var fieldStatusContainer = sysContainer.nestedContainer(keyedBy: FieldStatusKeys.self, forKey: .fieldStatus)
            var allFieldStatusContainer = fieldStatusContainer.nestedContainer(keyedBy: FieldItemCodingKeys.self, forKey: .all)
            try allFieldStatusContainer.encode(fieldStatus, forKey: .locale)
        }
    }
    
    func contains(searchText: String) -> Bool {
        return fieldStatus?.localizedCaseInsensitiveContains(searchText) ?? false
        || id.localizedCaseInsensitiveContains(searchText)
        || updatedAt.description.localizedCaseInsensitiveContains(searchText)
        || createdAt.description.localizedCaseInsensitiveContains(searchText)
    }
}
