// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_static_bearer_auth_response` (beta_managed_agents_static_bearer_auth_response.py).

import Foundation

/// Static bearer token credential details for an MCP server.
public struct BetaManagedAgentsStaticBearerAuthResponse: Codable, Hashable, Sendable {
    /// URL of the MCP server this credential authenticates against.
    public var mcpServerUrl: String
    public var type: String

    public init(mcpServerUrl: String, type: String = "static_bearer") {
        self.mcpServerUrl = mcpServerUrl
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case mcpServerUrl = "mcp_server_url"
        case type
    }
}
