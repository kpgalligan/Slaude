// Transformed from `anthropic.types.beta.beta_response_tool_change_mcp_tool_reference` (beta_response_tool_change_mcp_tool_reference.py).

import Foundation

/// Reference to a single MCP tool, by its server and its name on that
/// server, as a ``compaction`` block's ``tool_changes`` entry reports it.
/// Send it back unchanged with the block.
public struct BetaResponseToolChangeMCPToolReference: Codable, Hashable, Sendable {
    public var name: String
    public var serverName: String
    public var type: String

    public init(name: String, serverName: String, type: String = "mcp_tool_reference") {
        self.name = name
        self.serverName = serverName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case name
        case serverName = "server_name"
        case type
    }
}
