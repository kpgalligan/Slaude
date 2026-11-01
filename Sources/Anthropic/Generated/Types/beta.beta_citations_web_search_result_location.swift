// Transformed from `anthropic.types.beta.beta_citations_web_search_result_location` (beta_citations_web_search_result_location.py).

import Foundation

public struct BetaCitationsWebSearchResultLocation: Codable, Hashable, Sendable {
    public var citedText: String
    public var encryptedIndex: String
    public var title: String?
    public var type: String
    public var url: String

    public init(citedText: String, encryptedIndex: String, title: String? = nil, type: String = "web_search_result_location", url: String) {
        self.citedText = citedText
        self.encryptedIndex = encryptedIndex
        self.title = title
        self.type = type
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case citedText = "cited_text"
        case encryptedIndex = "encrypted_index"
        case title
        case type
        case url
    }
}
