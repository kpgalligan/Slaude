// Transformed from `anthropic.types.web_fetch_block` (web_fetch_block.py).

import Foundation

public struct WebFetchBlock: Codable, Hashable, Sendable {
    public var content: DocumentBlock
    /// ISO 8601 timestamp when the content was retrieved
    public var retrievedAt: String?
    public var type: String
    /// Fetched content URL
    public var url: String

    public init(content: DocumentBlock, retrievedAt: String? = nil, type: String = "web_fetch_result", url: String) {
        self.content = content
        self.retrievedAt = retrievedAt
        self.type = type
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case content
        case retrievedAt = "retrieved_at"
        case type
        case url
    }
}
