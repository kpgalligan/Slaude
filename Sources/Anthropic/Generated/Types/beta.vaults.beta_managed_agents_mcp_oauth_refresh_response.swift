// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_mcp_oauth_refresh_response` (beta_managed_agents_mcp_oauth_refresh_response.py).

import Foundation

/// OAuth refresh token configuration returned in credential responses.
public struct BetaManagedAgentsMCPOAuthRefreshResponse: Codable, Hashable, Sendable {
    /// The OAuth client ID used when refreshing the access token.
    public var clientId: String
    /// Token endpoint URL used to refresh the access token.
    public var tokenEndpoint: String
    public var tokenEndpointAuth: BetaManagedAgentsMCPOAuthRefreshResponse.TokenEndpointAuth
    /// OAuth resource indicator.
    public var resource: String?
    /// OAuth scope for the refresh request.
    public var scope: String?

    public init(clientId: String, tokenEndpoint: String, tokenEndpointAuth: BetaManagedAgentsMCPOAuthRefreshResponse.TokenEndpointAuth, resource: String? = nil, scope: String? = nil) {
        self.clientId = clientId
        self.tokenEndpoint = tokenEndpoint
        self.tokenEndpointAuth = tokenEndpointAuth
        self.resource = resource
        self.scope = scope
    }

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case tokenEndpoint = "token_endpoint"
        case tokenEndpointAuth = "token_endpoint_auth"
        case resource
        case scope
    }
}

extension BetaManagedAgentsMCPOAuthRefreshResponse {

    public indirect enum TokenEndpointAuth: Codable, Hashable, Sendable {
        case none(BetaManagedAgentsTokenEndpointAuthNoneResponse)
        case clientSecretBasic(BetaManagedAgentsTokenEndpointAuthBasicResponse)
        case clientSecretPost(BetaManagedAgentsTokenEndpointAuthPostResponse)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "none": self = .none(try BetaManagedAgentsTokenEndpointAuthNoneResponse(from: decoder))
            case "client_secret_basic": self = .clientSecretBasic(try BetaManagedAgentsTokenEndpointAuthBasicResponse(from: decoder))
            case "client_secret_post": self = .clientSecretPost(try BetaManagedAgentsTokenEndpointAuthPostResponse(from: decoder))
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
