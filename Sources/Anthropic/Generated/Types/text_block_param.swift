// Transformed from `anthropic.types.text_block_param` (text_block_param.py).

import Foundation

public struct TextBlockParam: Codable, Hashable, Sendable {
    public var text: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    public var citations: [TextCitationParam]??

    public init(text: String, type: String = "text", cacheControl: CacheControlEphemeralParam?? = nil, citations: [TextCitationParam]?? = nil) {
        self.text = text
        self.type = type
        self.cacheControl = cacheControl
        self.citations = citations
    }

    enum CodingKeys: String, CodingKey {
        case text
        case type
        case cacheControl = "cache_control"
        case citations
    }
}
