// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_mcp_oauth_update_params` (beta_managed_agents_mcp_oauth_update_params.py).

import Foundation

/// Parameters for updating an MCP OAuth credential.
///
/// The `mcp_server_url` is immutable.
public struct BetaManagedAgentsMCPOAuthUpdateParams: Codable, Hashable, Sendable {
    public var type: String
    /// The new OAuth access token to replace the stored one.
    public var accessToken: String??
    /// When the credential's access token expires, in RFC 3339.
    ///
    /// Leave it out to keep the stored expiry.
    ///
    /// If you send a new `access_token`, send its `expires_at` too, or the new token
    /// keeps the old expiry.
    ///
    /// Must be in the future.
    public var expiresAt: ExpiresAt??
    /// Updated refresh token configuration.
    public var refresh: BetaManagedAgentsMCPOAuthRefreshUpdateParams??

    public init(type: String = "mcp_oauth", accessToken: String?? = nil, expiresAt: ExpiresAt?? = nil, refresh: BetaManagedAgentsMCPOAuthRefreshUpdateParams?? = nil) {
        self.type = type
        self.accessToken = accessToken
        self.expiresAt = expiresAt
        self.refresh = refresh
    }

    enum CodingKeys: String, CodingKey {
        case type
        case accessToken = "access_token"
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
