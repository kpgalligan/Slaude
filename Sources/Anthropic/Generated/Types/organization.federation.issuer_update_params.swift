// Transformed from `anthropic.types.organization.federation.issuer_update_params` (issuer_update_params.py).

import Foundation

public struct IssuerUpdateParams: Codable, Hashable, Sendable {
    /// Whether the jwt-bearer exchange enforces JTI single-use (replay protection) for
    /// tokens from this issuer. Applies only to assertions carrying a `jti` claim;
    /// tokens without one are accepted without single-use enforcement.
    public var checkJti: Bool??
    /// Replaces the `iss` claim value to match against.
    ///
    /// For discovery-mode issuers without a `discovery_base`, this is also the URL
    /// Anthropic fetches the OIDC discovery document and signing keys from, so changing
    /// it repoints the JWKS source. Changing the issuer URL to a well-known shared
    /// platform is rejected while any live rule under this issuer would not constrain
    /// tenant identity.
    public var issuerUrl: String??
    /// Replaces the entire JWKS configuration.
    public var jwks: IssuerUpdateParams.JWKS??
    /// Only `false` is accepted, to re-enable polling after the system pauses it.
    ///
    /// Polling is paused automatically; sending `true` is rejected.
    public var jwksPollingDisabled: Bool??
    /// Maximum allowed iat→exp spread for assertions from this issuer (1-176400
    /// seconds, i.e. up to 49h). Assertions must carry both `iat` and `exp`; a missing
    /// `iat` is rejected.
    public var maxJwtLifetimeSeconds: Int??
    /// Replaces the slug identifier (lowercase, digits, hyphens).
    ///
    /// Unique within the organization; a duplicate name returns 409.
    public var name: String??

    public init(checkJti: Bool?? = nil, issuerUrl: String?? = nil, jwks: IssuerUpdateParams.JWKS?? = nil, jwksPollingDisabled: Bool?? = nil, maxJwtLifetimeSeconds: Int?? = nil, name: String?? = nil) {
        self.checkJti = checkJti
        self.issuerUrl = issuerUrl
        self.jwks = jwks
        self.jwksPollingDisabled = jwksPollingDisabled
        self.maxJwtLifetimeSeconds = maxJwtLifetimeSeconds
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case checkJti = "check_jti"
        case issuerUrl = "issuer_url"
        case jwks
        case jwksPollingDisabled = "jwks_polling_disabled"
        case maxJwtLifetimeSeconds = "max_jwt_lifetime_seconds"
        case name
    }
}

extension IssuerUpdateParams {

    public indirect enum JWKS: Codable, Hashable, Sendable {
        case discovery(JWKSDiscoveryParam)
        case explicitUrl(JWKSExplicitURLParam)
        case inline(JWKSInlineParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "discovery": self = .discovery(try JWKSDiscoveryParam(from: decoder))
            case "explicit_url": self = .explicitUrl(try JWKSExplicitURLParam(from: decoder))
            case "inline": self = .inline(try JWKSInlineParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .discovery(let v): try v.encode(to: encoder)
            case .explicitUrl(let v): try v.encode(to: encoder)
            case .inline(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
