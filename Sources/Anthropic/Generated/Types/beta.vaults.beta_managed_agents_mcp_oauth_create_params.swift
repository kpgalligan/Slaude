// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_mcp_oauth_create_params` (beta_managed_agents_mcp_oauth_create_params.py).

import Foundation

/// Parameters for creating an MCP OAuth credential.
public struct BetaManagedAgentsMCPOAuthCreateParams: Codable, Hashable, Sendable {
    /// The OAuth access token to send to the MCP server.
    public var accessToken: String
    /// URL of the MCP server this credential authenticates against.
    public var mcpServerURL: String
    public var type: String
    /// When `access_token` expires, in RFC 3339.
    ///
    /// Must be in the future.
    public var expiresAt: ExpiresAt??
    /// Refresh token configuration, if the credential supports token refresh.
    public var refresh: BetaManagedAgentsMCPOAuthRefreshParams??

    public init(accessToken: String, mcpServerURL: String, type: String = "mcp_oauth", expiresAt: ExpiresAt?? = nil, refresh: BetaManagedAgentsMCPOAuthRefreshParams?? = nil) {
        self.accessToken = accessToken
        self.mcpServerURL = mcpServerURL
        self.type = type
        self.expiresAt = expiresAt
        self.refresh = refresh
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case mcpServerURL = "mcp_server_url"
        case type
        case expiresAt = "expires_at"
        case refresh
    }

    public indirect enum ExpiresAt: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(Date)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? Date(from: decoder) { self = .date(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .date(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
