//
//  TextNode.swift
//  The Feed
//
//  Created by Dylan Gattey on 12/25/24.
//

/**
 Encapsulates a rich text node that has other content inside or a single value - it's self-referential, though there are certain rules like only one `document` type at the top level. Either content or value will be set, not both, and definitely one of them.
 */
struct TextNode: Equatable, Codable, Hashable {
    let content: [TextNode]?
    let value: String?
    let nodeType: NodeType
    let data: TextNodeData
    let marks: [Mark]?
}

struct TextNodeData: Equatable, Codable, Hashable {
    let uri: String?
}

enum NodeType: String, Equatable, Codable, Hashable {
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
}

struct Mark: Equatable, Codable, Hashable {
    let type: MarkType
}

enum MarkType: String, Equatable, Codable, Hashable {
    case bold
    case italic
    case underline
    case code
}
