// Transformed from `anthropic.types.beta.beta_tool_change_mcp_toolset_reference_param` (beta_tool_change_mcp_toolset_reference_param.py).

import Foundation

/// Reference to every tool in the named MCP server's toolset.
public struct BetaToolChangeMCPToolsetReferenceParam: Codable, Hashable, Sendable {
    public var serverName: String
    public var type: String

    public init(serverName: String, type: String = "mcp_toolset_reference") {
        self.serverName = serverName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case serverName = "server_name"
        case type
    }
}
