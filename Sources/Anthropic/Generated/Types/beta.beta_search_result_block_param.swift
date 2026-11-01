// Transformed from `anthropic.types.beta.beta_search_result_block_param` (beta_search_result_block_param.py).

import Foundation

public struct BetaSearchResultBlockParam: Codable, Hashable, Sendable {
    public var content: [BetaTextBlockParam]
    public var source: String
    public var title: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    public var citations: BetaCitationsConfigParamParam?

    public init(content: [BetaTextBlockParam], source: String, title: String, type: String = "search_result", cacheControl: BetaCacheControlEphemeralParam?? = nil, citations: BetaCitationsConfigParamParam? = nil) {
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
