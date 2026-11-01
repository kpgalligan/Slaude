// Transformed from `anthropic.types.tool_reference_block_param` (tool_reference_block_param.py).

import Foundation

/// Tool reference block that can be included in tool_result content.
public struct ToolReferenceBlockParam: Codable, Hashable, Sendable {
    public var toolName: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??

    public init(toolName: String, type: String = "tool_reference", cacheControl: CacheControlEphemeralParam?? = nil) {
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
