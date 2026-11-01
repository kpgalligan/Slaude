// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_mcp_oauth_refresh_update_params` (beta_managed_agents_mcp_oauth_refresh_update_params.py).

import Foundation

/// Parameters for updating OAuth refresh token configuration.
public struct BetaManagedAgentsMCPOAuthRefreshUpdateParams: Codable, Hashable, Sendable {
    /// The new OAuth refresh token to replace the stored one.
    public var refreshToken: String??
    /// The new OAuth scope for refresh requests.
    ///
    /// Send an empty string to clear the stored scope.
    public var scope: String??
    public var tokenEndpointAuth: BetaManagedAgentsMCPOAuthRefreshUpdateParams.TokenEndpointAuth?

    public init(refreshToken: String?? = nil, scope: String?? = nil, tokenEndpointAuth: BetaManagedAgentsMCPOAuthRefreshUpdateParams.TokenEndpointAuth? = nil) {
        self.refreshToken = refreshToken
        self.scope = scope
        self.tokenEndpointAuth = tokenEndpointAuth
    }

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case scope
        case tokenEndpointAuth = "token_endpoint_auth"
    }
}

extension BetaManagedAgentsMCPOAuthRefreshUpdateParams {

    public indirect enum TokenEndpointAuth: Codable, Hashable, Sendable {
        case clientSecretBasic(BetaManagedAgentsTokenEndpointAuthBasicUpdateParam)
        case clientSecretPost(BetaManagedAgentsTokenEndpointAuthPostUpdateParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "client_secret_basic": self = .clientSecretBasic(try BetaManagedAgentsTokenEndpointAuthBasicUpdateParam(from: decoder))
            case "client_secret_post": self = .clientSecretPost(try BetaManagedAgentsTokenEndpointAuthPostUpdateParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .clientSecretBasic(let v): try v.encode(to: encoder)
            case .clientSecretPost(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
