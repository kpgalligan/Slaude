// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_limited_credential_networking_response` (beta_managed_agents_limited_credential_networking_response.py).

import Foundation

/// The secret is substituted only on requests to the listed hosts.
public struct BetaManagedAgentsLimitedCredentialNetworkingResponse: Codable, Hashable, Sendable {
    /// The destination hosts of the outbound requests that the credential's secret is
    /// substituted into.
    ///
    /// An entry matches the request host exactly. An entry such as `*.example.com`
    /// matches any subdomain of `example.com` but not `example.com` itself.
    public var allowedHosts: [String]
    public var type: String

    public init(allowedHosts: [String], type: String = "limited") {
        self.allowedHosts = allowedHosts
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case allowedHosts = "allowed_hosts"
        case type
    }
}
