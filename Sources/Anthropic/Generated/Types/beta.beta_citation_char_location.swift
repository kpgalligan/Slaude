// Transformed from `anthropic.types.beta.beta_citation_char_location` (beta_citation_char_location.py).

import Foundation

public struct BetaCitationCharLocation: Codable, Hashable, Sendable {
    public var citedText: String
    public var documentIndex: Int
    public var documentTitle: String?
    public var endCharIndex: Int
    public var fileID: String?
    public var startCharIndex: Int
    public var type: String

    public init(citedText: String, documentIndex: Int, documentTitle: String? = nil, endCharIndex: Int, fileID: String? = nil, startCharIndex: Int, type: String = "char_location") {
        self.citedText = citedText
        self.documentIndex = documentIndex
        self.documentTitle = documentTitle
        self.endCharIndex = endCharIndex
        self.fileID = fileID
        self.startCharIndex = startCharIndex
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citedText = "cited_text"
        case documentIndex = "document_index"
        case documentTitle = "document_title"
        case endCharIndex = "end_char_index"
        case fileID = "file_id"
        case startCharIndex = "start_char_index"
        case type
    }
}
