// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_mcp_oauth_auth_response` (beta_managed_agents_mcp_oauth_auth_response.py).

import Foundation

/// OAuth credential details for an MCP server.
public struct BetaManagedAgentsMCPOAuthAuthResponse: Codable, Hashable, Sendable {
    /// URL of the MCP server this credential authenticates against.
    public var mcpServerURL: String
    public var type: String
    /// When the credential's access token expires, in RFC 3339.
    ///
    /// Absent if the expiry isn't known.
    public var expiresAt: Date?
    /// Refresh token configuration, if the credential supports token refresh.
    public var refresh: BetaManagedAgentsMCPOAuthRefreshResponse?

    public init(mcpServerURL: String, type: String = "mcp_oauth", expiresAt: Date? = nil, refresh: BetaManagedAgentsMCPOAuthRefreshResponse? = nil) {
        self.mcpServerURL = mcpServerURL
        self.type = type
        self.expiresAt = expiresAt
        self.refresh = refresh
    }

    enum CodingKeys: String, CodingKey {
        case mcpServerURL = "mcp_server_url"
        case type
        case expiresAt = "expires_at"
        case refresh
    }
}
