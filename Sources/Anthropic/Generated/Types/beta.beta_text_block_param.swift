// Transformed from `anthropic.types.beta.beta_text_block_param` (beta_text_block_param.py).

import Foundation

public struct BetaTextBlockParam: Codable, Hashable, Sendable {
    public var text: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    public var citations: [BetaTextCitationParam]??

    public init(text: String, type: String = "text", cacheControl: BetaCacheControlEphemeralParam?? = nil, citations: [BetaTextCitationParam]?? = nil) {
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
