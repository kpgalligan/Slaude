// Transformed from `anthropic.types.citation_page_location` (citation_page_location.py).

import Foundation

public struct CitationPageLocation: Codable, Hashable, Sendable {
    public var citedText: String
    public var documentIndex: Int
    public var documentTitle: String?
    public var endPageNumber: Int
    public var fileId: String?
    public var startPageNumber: Int
    public var type: String

    public init(citedText: String, documentIndex: Int, documentTitle: String? = nil, endPageNumber: Int, fileId: String? = nil, startPageNumber: Int, type: String = "page_location") {
        self.citedText = citedText
        self.documentIndex = documentIndex
        self.documentTitle = documentTitle
        self.endPageNumber = endPageNumber
        self.fileId = fileId
        self.startPageNumber = startPageNumber
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citedText = "cited_text"
        case documentIndex = "document_index"
        case documentTitle = "document_title"
        case endPageNumber = "end_page_number"
        case fileId = "file_id"
        case startPageNumber = "start_page_number"
        case type
    }
}
