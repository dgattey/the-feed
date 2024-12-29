//
//  SysContent.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/23/24.
//

import Foundation

struct SysContent: IdentifiableModel & SearchableModel & EmptyCreatableModel {
    let id: String
    let linkType: String?
    let type: String
    let updatedAt: Date?
    let createdAt: Date?
    let fieldStatus: String?
    
    init() {
        let id = String(describing: Date.now)
        self.init(id: id)
    }
    
    init(id: String = String(describing: Date.now)) {
        self.id = id
        linkType = nil
        type = ""
        updatedAt = nil
        createdAt = nil
        fieldStatus = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case sys
    }
    
    enum SysCodingKeys: String, CodingKey {
        case id
        case linkType
        case type
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
        linkType = try? sysContainer.decode(String.self, forKey: .linkType)
        type = try sysContainer.decode(String.self, forKey: .type)
        
        if let updatedAtString = try? sysContainer.decode(String.self, forKey: .updatedAt) {
            updatedAt = SysContent.dateFormatter.date(from: updatedAtString)!
        } else {
            updatedAt = nil
        }
        
        if let createdAtString = try? sysContainer.decode(String.self, forKey: .createdAt) {
            createdAt = SysContent.dateFormatter.date(from: createdAtString)!
        } else {
            createdAt = nil
        }
        
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
        try sysContainer.encode(linkType, forKey: .linkType)
        try sysContainer.encode(type, forKey: .type)
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
        || linkType?.localizedCaseInsensitiveContains(searchText) ?? false
        || type.localizedCaseInsensitiveContains(searchText)
    }
}
