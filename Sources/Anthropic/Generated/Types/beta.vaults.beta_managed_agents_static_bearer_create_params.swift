// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_static_bearer_create_params` (beta_managed_agents_static_bearer_create_params.py).

import Foundation

/// Parameters for creating a static bearer token credential.
public struct BetaManagedAgentsStaticBearerCreateParams: Codable, Hashable, Sendable {
    /// The static bearer token to send to the MCP server, such as an API key or
    /// personal access token.
    public var token: String
    /// URL of the MCP server this credential authenticates against.
    public var mcpServerUrl: String
    public var type: String

    public init(token: String, mcpServerUrl: String, type: String = "static_bearer") {
        self.token = token
        self.mcpServerUrl = mcpServerUrl
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case token
        case mcpServerUrl = "mcp_server_url"
        case type
    }
}
