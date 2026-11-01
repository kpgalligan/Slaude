// Transformed from `anthropic.types.web_fetch_block_param` (web_fetch_block_param.py).

import Foundation

public struct WebFetchBlockParam: Codable, Hashable, Sendable {
    public var content: DocumentBlockParam
    public var type: String
    /// Fetched content URL
    public var url: String
    /// ISO 8601 timestamp when the content was retrieved
    public var retrievedAt: String??

    public init(content: DocumentBlockParam, type: String = "web_fetch_result", url: String, retrievedAt: String?? = nil) {
        self.content = content
        self.type = type
        self.url = url
        self.retrievedAt = retrievedAt
    }

    enum CodingKeys: String, CodingKey {
        case content
        case type
        case url
        case retrievedAt = "retrieved_at"
    }
}
