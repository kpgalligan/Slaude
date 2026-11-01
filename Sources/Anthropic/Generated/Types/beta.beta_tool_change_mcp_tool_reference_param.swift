// Transformed from `anthropic.types.beta.beta_tool_change_mcp_tool_reference_param` (beta_tool_change_mcp_tool_reference_param.py).

import Foundation

/// Reference to a single MCP tool by its server and remote name; the
/// same ``server_name``/``name`` pair ``mcp_tool_use`` carries.
public struct BetaToolChangeMCPToolReferenceParam: Codable, Hashable, Sendable {
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
