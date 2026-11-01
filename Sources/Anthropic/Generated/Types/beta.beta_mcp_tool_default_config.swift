// Transformed from `anthropic.types.beta.beta_mcp_tool_default_config` (beta_mcp_tool_default_config.py).

import Foundation

/// Default configuration for tools in an MCP toolset.
public struct BetaMCPToolDefaultConfig: Codable, Hashable, Sendable {
    public var deferLoading: Bool?
    public var enabled: Bool?

    public init(deferLoading: Bool? = nil, enabled: Bool? = nil) {
        self.deferLoading = deferLoading
        self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case deferLoading = "defer_loading"
        case enabled
    }
}
