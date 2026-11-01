// Transformed from `anthropic.types.organization.federation.jwks_discovery` (jwks_discovery.py).

import Foundation

/// JWKS via the issuer's OIDC discovery document.
public struct JWKSDiscovery: Codable, Hashable, Sendable {
    public var type: String
    /// Optional custom CA (PEM) for TLS verification of the JWKS fetch.
    public var caCertPem: String?
    /// Set when the discovery URL differs from `issuer_url`.
    public var discoveryBase: String?

    public init(type: String = "discovery", caCertPem: String? = nil, discoveryBase: String? = nil) {
        self.type = type
        self.caCertPem = caCertPem
        self.discoveryBase = discoveryBase
    }

    enum CodingKeys: String, CodingKey {
        case type
        case caCertPem = "ca_cert_pem"
        case discoveryBase = "discovery_base"
    }
}
