//
//  TextNode.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/25/24.
//

/**
 Encapsulates a rich text node that has other content inside or a single value - it's self-referential, though there are certain rules like only one `document` type at the top level. Either content or value will be set, not both, and definitely one of them.
 */
struct TextNode: SearchableModel {
    let content: [TextNode]?
    let value: String?
    let nodeType: NodeType
    let data: TextNodeData
    let marks: [Mark]?
    
    func contains(searchText: String) -> Bool {
        return nodeType.contains(searchText: searchText)
        || data.contains(searchText: searchText)
        || marks?.contains(where: { $0.contains(searchText: searchText) }) ?? false
        || value?.localizedCaseInsensitiveContains(searchText) ?? false
        || content?.contains(where: { $0.contains(searchText: searchText) }) ?? false
    }
}

struct TextNodeData: SearchableModel {
    let uri: String?
    
    func contains(searchText: String) -> Bool {
        return uri?.localizedCaseInsensitiveContains(searchText) ?? false
    }
}

enum NodeType: String, SearchableModel {
    case blockquote
    case document
    case heading1 = "heading-1"
    case heading2 = "heading-2"
    case heading3 = "heading-3"
    case heading4 = "heading-4"
    case heading5 = "heading-5"
    case heading6 = "heading-6"
    case horizontalLine = "hr"
    case hyperlink
    case listItem = "list-item"
    case orderedList = "ordered-list"
    case paragraph
    case text
    case unorderedList = "unordered-list"
    
    func contains(searchText: String) -> Bool {
        return rawValue.localizedCaseInsensitiveContains(searchText)
    }
}

struct Mark: SearchableModel {
    let type: MarkType
    
    func contains(searchText: String) -> Bool {
        return type.contains(searchText: searchText)
    }
}

enum MarkType: String, SearchableModel {
    case bold
    case italic
    case underline
    case code
    
    func contains(searchText: String) -> Bool {
        return rawValue.localizedCaseInsensitiveContains(searchText)
    }
}
