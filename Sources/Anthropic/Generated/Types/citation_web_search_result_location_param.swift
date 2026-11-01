// Transformed from `anthropic.types.citation_web_search_result_location_param` (citation_web_search_result_location_param.py).

import Foundation

public struct CitationWebSearchResultLocationParam: Codable, Hashable, Sendable {
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

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(citedText, forKey: .citedText)
        try c.encode(encryptedIndex, forKey: .encryptedIndex)
        try c.encode(title, forKey: .title)
        try c.encode(type, forKey: .type)
        try c.encode(url, forKey: .url)
    }
}
