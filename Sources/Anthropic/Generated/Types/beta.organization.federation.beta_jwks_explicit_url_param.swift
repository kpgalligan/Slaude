// Transformed from `anthropic.types.beta.organization.federation.beta_jwks_explicit_url_param` (beta_jwks_explicit_url_param.py).

import Foundation

/// JWKS fetched from a fixed endpoint.
public struct BetaJWKSExplicitURLParam: Codable, Hashable, Sendable {
    public var type: String
    /// JWKS endpoint.
    public var url: String
    /// Optional custom CA (PEM) for TLS verification of the JWKS fetch.
    public var caCertPem: String??

    public init(type: String = "explicit_url", url: String, caCertPem: String?? = nil) {
        self.type = type
        self.url = url
        self.caCertPem = caCertPem
    }

    enum CodingKeys: String, CodingKey {
        case type
        case url
        case caCertPem = "ca_cert_pem"
    }
}
