// Transformed from `anthropic.types.beta.beta_citation_page_location_param` (beta_citation_page_location_param.py).

import Foundation

public struct BetaCitationPageLocationParam: Codable, Hashable, Sendable {
    public var citedText: String
    public var documentIndex: Int
    public var documentTitle: String?
    public var endPageNumber: Int
    public var startPageNumber: Int
    public var type: String

    public init(citedText: String, documentIndex: Int, documentTitle: String? = nil, endPageNumber: Int, startPageNumber: Int, type: String = "page_location") {
        self.citedText = citedText
        self.documentIndex = documentIndex
        self.documentTitle = documentTitle
        self.endPageNumber = endPageNumber
        self.startPageNumber = startPageNumber
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citedText = "cited_text"
        case documentIndex = "document_index"
        case documentTitle = "document_title"
        case endPageNumber = "end_page_number"
        case startPageNumber = "start_page_number"
        case type
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(citedText, forKey: .citedText)
        try c.encode(documentIndex, forKey: .documentIndex)
        try c.encode(documentTitle, forKey: .documentTitle)
        try c.encode(endPageNumber, forKey: .endPageNumber)
        try c.encode(startPageNumber, forKey: .startPageNumber)
        try c.encode(type, forKey: .type)
    }
}
