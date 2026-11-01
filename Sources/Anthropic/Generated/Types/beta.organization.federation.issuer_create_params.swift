// Transformed from `anthropic.types.beta.organization.federation.issuer_create_params` (issuer_create_params.py).

import Foundation

public struct BetaOrganizationFederationIssuerCreateParams: Codable, Hashable, Sendable {
    /// The `iss` claim value to match against.
    public var issuerURL: String
    /// Slug identifier (lowercase, digits, hyphens).
    ///
    /// Unique within the organization; a duplicate name returns 409.
    public var name: String
    /// Whether the jwt-bearer exchange enforces JTI single-use (replay protection) for
    /// tokens from this issuer. Defaults to true. Applies only to assertions carrying a
    /// `jti` claim; tokens without one are accepted without single-use enforcement.
    public var checkJti: Bool??
    /// How signing keys are obtained. Defaults to OIDC discovery.
    public var jwks: BetaOrganizationFederationIssuerCreateParams.JWKS?
    /// Maximum allowed iat→exp spread for assertions from this issuer (1-176400
    /// seconds, i.e. up to 49h). Defaults to 3600 (1h). Assertions must carry both
    /// `iat` and `exp`; a missing `iat` is rejected.
    public var maxJwtLifetimeSeconds: Int??
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(issuerURL: String, name: String, checkJti: Bool?? = nil, jwks: BetaOrganizationFederationIssuerCreateParams.JWKS? = nil, maxJwtLifetimeSeconds: Int?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.issuerURL = issuerURL
        self.name = name
        self.checkJti = checkJti
        self.jwks = jwks
        self.maxJwtLifetimeSeconds = maxJwtLifetimeSeconds
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case issuerURL = "issuer_url"
        case name
        case checkJti = "check_jti"
        case jwks
        case maxJwtLifetimeSeconds = "max_jwt_lifetime_seconds"
        case betas
    }
}

extension BetaOrganizationFederationIssuerCreateParams {

    public indirect enum JWKS: Codable, Hashable, Sendable {
        case discovery(BetaJWKSDiscoveryParam)
        case explicitUrl(BetaJWKSExplicitURLParam)
        case inline(BetaJWKSInlineParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "discovery": self = .discovery(try BetaJWKSDiscoveryParam(from: decoder))
            case "explicit_url": self = .explicitUrl(try BetaJWKSExplicitURLParam(from: decoder))
            case "inline": self = .inline(try BetaJWKSInlineParam(from: decoder))
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
