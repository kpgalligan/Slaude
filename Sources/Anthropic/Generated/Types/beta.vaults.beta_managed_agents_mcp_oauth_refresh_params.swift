// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_mcp_oauth_refresh_params` (beta_managed_agents_mcp_oauth_refresh_params.py).

import Foundation

/// OAuth refresh token parameters for creating a credential with refresh support.
public struct BetaManagedAgentsMCPOAuthRefreshParams: Codable, Hashable, Sendable {
    /// The OAuth client ID to use when refreshing the access token.
    ///
    /// It can't be changed after the credential is created.
    public var clientId: String
    /// The OAuth refresh token that the API uses to get a new access token when the
    /// current one expires.
    public var refreshToken: String
    /// Token endpoint URL used to refresh the access token.
    public var tokenEndpoint: String
    public var tokenEndpointAuth: BetaManagedAgentsMCPOAuthRefreshParams.TokenEndpointAuth
    /// OAuth resource indicator.
    public var resource: String??
    /// OAuth scope for the refresh request.
    public var scope: String??

    public init(clientId: String, refreshToken: String, tokenEndpoint: String, tokenEndpointAuth: BetaManagedAgentsMCPOAuthRefreshParams.TokenEndpointAuth, resource: String?? = nil, scope: String?? = nil) {
        self.clientId = clientId
        self.refreshToken = refreshToken
        self.tokenEndpoint = tokenEndpoint
        self.tokenEndpointAuth = tokenEndpointAuth
        self.resource = resource
        self.scope = scope
    }

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case refreshToken = "refresh_token"
        case tokenEndpoint = "token_endpoint"
        case tokenEndpointAuth = "token_endpoint_auth"
        case resource
        case scope
    }
}

extension BetaManagedAgentsMCPOAuthRefreshParams {

    public indirect enum TokenEndpointAuth: Codable, Hashable, Sendable {
        case none(BetaManagedAgentsTokenEndpointAuthNoneParam)
        case clientSecretBasic(BetaManagedAgentsTokenEndpointAuthBasicParam)
        case clientSecretPost(BetaManagedAgentsTokenEndpointAuthPostParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "none": self = .none(try BetaManagedAgentsTokenEndpointAuthNoneParam(from: decoder))
            case "client_secret_basic": self = .clientSecretBasic(try BetaManagedAgentsTokenEndpointAuthBasicParam(from: decoder))
            case "client_secret_post": self = .clientSecretPost(try BetaManagedAgentsTokenEndpointAuthPostParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .none(let v): try v.encode(to: encoder)
            case .clientSecretBasic(let v): try v.encode(to: encoder)
            case .clientSecretPost(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
