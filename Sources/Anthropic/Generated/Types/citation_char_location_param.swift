// Transformed from `anthropic.types.citation_char_location_param` (citation_char_location_param.py).

import Foundation

public struct CitationCharLocationParam: Codable, Hashable, Sendable {
    public var citedText: String
    public var documentIndex: Int
    public var documentTitle: String?
    public var endCharIndex: Int
    public var startCharIndex: Int
    public var type: String

    public init(citedText: String, documentIndex: Int, documentTitle: String? = nil, endCharIndex: Int, startCharIndex: Int, type: String = "char_location") {
        self.citedText = citedText
        self.documentIndex = documentIndex
        self.documentTitle = documentTitle
        self.endCharIndex = endCharIndex
        self.startCharIndex = startCharIndex
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citedText = "cited_text"
        case documentIndex = "document_index"
        case documentTitle = "document_title"
        case endCharIndex = "end_char_index"
        case startCharIndex = "start_char_index"
        case type
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(citedText, forKey: .citedText)
        try c.encode(documentIndex, forKey: .documentIndex)
        try c.encode(documentTitle, forKey: .documentTitle)
        try c.encode(endCharIndex, forKey: .endCharIndex)
        try c.encode(startCharIndex, forKey: .startCharIndex)
        try c.encode(type, forKey: .type)
    }
}
