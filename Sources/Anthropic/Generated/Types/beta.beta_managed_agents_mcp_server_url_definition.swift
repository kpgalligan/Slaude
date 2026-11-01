// Transformed from `anthropic.types.beta.beta_managed_agents_mcp_server_url_definition` (beta_managed_agents_mcp_server_url_definition.py).

import Foundation

/// URL-based MCP server connection as returned in API responses.
public struct BetaManagedAgentsMCPServerURLDefinition: Codable, Hashable, Sendable {
    public var name: String
    public var type: String
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
