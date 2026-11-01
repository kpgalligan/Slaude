// Transformed from `anthropic.types.search_result_block_param` (search_result_block_param.py).

import Foundation

public struct SearchResultBlockParam: Codable, Hashable, Sendable {
    public var content: [TextBlockParam]
    public var source: String
    public var title: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    public var citations: CitationsConfigParam?

    public init(content: [TextBlockParam], source: String, title: String, type: String = "search_result", cacheControl: CacheControlEphemeralParam?? = nil, citations: CitationsConfigParam? = nil) {
        self.content = content
        self.source = source
        self.title = title
        self.type = type
        self.cacheControl = cacheControl
        self.citations = citations
    }

    enum CodingKeys: String, CodingKey {
        case content
        case source
        case title
        case type
        case cacheControl = "cache_control"
        case citations
    }
}
