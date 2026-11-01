// Transformed from `anthropic.types.beta.beta_citation_page_location` (beta_citation_page_location.py).

import Foundation

public struct BetaCitationPageLocation: Codable, Hashable, Sendable {
    public var citedText: String
    public var documentIndex: Int
    public var documentTitle: String?
    public var endPageNumber: Int
    public var fileID: String?
    public var startPageNumber: Int
    public var type: String

    public init(citedText: String, documentIndex: Int, documentTitle: String? = nil, endPageNumber: Int, fileID: String? = nil, startPageNumber: Int, type: String = "page_location") {
        self.citedText = citedText
        self.documentIndex = documentIndex
        self.documentTitle = documentTitle
        self.endPageNumber = endPageNumber
        self.fileID = fileID
        self.startPageNumber = startPageNumber
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citedText = "cited_text"
        case documentIndex = "document_index"
        case documentTitle = "document_title"
        case endPageNumber = "end_page_number"
        case fileID = "file_id"
        case startPageNumber = "start_page_number"
        case type
    }
}
