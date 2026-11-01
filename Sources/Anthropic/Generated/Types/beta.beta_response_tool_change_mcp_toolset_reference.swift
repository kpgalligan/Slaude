// Transformed from `anthropic.types.beta.beta_response_tool_change_mcp_toolset_reference` (beta_response_tool_change_mcp_toolset_reference.py).

import Foundation

/// Reference to every tool in the named MCP server's toolset, as a
/// ``compaction`` block's ``tool_changes`` entry reports it. Send it back
/// unchanged with the block.
public struct BetaResponseToolChangeMCPToolsetReference: Codable, Hashable, Sendable {
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
