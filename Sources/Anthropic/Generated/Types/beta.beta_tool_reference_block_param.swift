// Transformed from `anthropic.types.beta.beta_tool_reference_block_param` (beta_tool_reference_block_param.py).

import Foundation

/// Tool reference block that can be included in tool_result content.
public struct BetaToolReferenceBlockParam: Codable, Hashable, Sendable {
    public var toolName: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??

    public init(toolName: String, type: String = "tool_reference", cacheControl: BetaCacheControlEphemeralParam?? = nil) {
        self.toolName = toolName
        self.type = type
        self.cacheControl = cacheControl
    }

    enum CodingKeys: String, CodingKey {
        case toolName = "tool_name"
        case type
        case cacheControl = "cache_control"
    }
}
