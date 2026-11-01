// Transformed from `anthropic.types.citation_char_location` (citation_char_location.py).

import Foundation

public struct CitationCharLocation: Codable, Hashable, Sendable {
    public var citedText: String
    public var documentIndex: Int
    public var documentTitle: String?
    public var endCharIndex: Int
    public var fileId: String?
    public var startCharIndex: Int
    public var type: String

    public init(citedText: String, documentIndex: Int, documentTitle: String? = nil, endCharIndex: Int, fileId: String? = nil, startCharIndex: Int, type: String = "char_location") {
        self.citedText = citedText
        self.documentIndex = documentIndex
        self.documentTitle = documentTitle
        self.endCharIndex = endCharIndex
        self.fileId = fileId
        self.startCharIndex = startCharIndex
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citedText = "cited_text"
        case documentIndex = "document_index"
        case documentTitle = "document_title"
        case endCharIndex = "end_char_index"
        case fileId = "file_id"
        case startCharIndex = "start_char_index"
        case type
    }
}
