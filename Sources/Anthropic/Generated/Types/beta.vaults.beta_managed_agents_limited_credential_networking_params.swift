// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_limited_credential_networking_params` (beta_managed_agents_limited_credential_networking_params.py).

import Foundation

/// Substitute the secret only on requests to the listed hosts.
public struct BetaManagedAgentsLimitedCredentialNetworkingParams: Codable, Hashable, Sendable {
    /// The destination hosts of the outbound requests that the credential's secret is
    /// substituted into.
    ///
    /// Each entry is a bare hostname (`api.example.com`), an IPv4 address
    /// (`192.0.2.1`), or a `*.` wildcard (`*.example.com`). URLs, ports, paths, and
    /// IPv6 addresses aren't accepted. The list can have up to 16 entries.
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
