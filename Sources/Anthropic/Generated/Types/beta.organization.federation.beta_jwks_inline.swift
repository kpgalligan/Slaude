// Transformed from `anthropic.types.beta.organization.federation.beta_jwks_inline` (beta_jwks_inline.py).

import Foundation

/// JWKS supplied directly; no network fetch.
public struct BetaJWKSInline: Codable, Hashable, Sendable {
    /// Inline JWK objects.
    public var keys: [[String: JSONValue]]
    public var type: String

    public init(keys: [[String: JSONValue]], type: String = "inline") {
        self.keys = keys
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case keys
        case type
    }
}
