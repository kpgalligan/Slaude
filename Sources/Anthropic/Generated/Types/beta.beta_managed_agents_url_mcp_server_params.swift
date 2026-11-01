// Transformed from `anthropic.types.beta.beta_managed_agents_url_mcp_server_params` (beta_managed_agents_url_mcp_server_params.py).

import Foundation

/// URL-based MCP server connection.
public struct BetaManagedAgentsURLMCPServerParams: Codable, Hashable, Sendable {
    /// Unique name for this server, referenced by mcp_toolset configurations.
    ///
    /// 1-255 characters.
    public var name: String
    public var type: String
    /// Endpoint URL for the MCP server.
    public var url: String

    public init(name: String, type: String = "url", url: String) {
        self.name = name
        self.type = type
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case url
    }
}
