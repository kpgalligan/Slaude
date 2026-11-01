// Transformed from `anthropic.types.beta.organization.federation.beta_federation_issuer` (beta_federation_issuer.py).

import Foundation

/// Registered external OIDC identity provider.
///
/// Records an external IdP the organization trusts for the RFC 7523
/// jwt-bearer grant. The `issuer_url` must match the JWT `iss` claim exactly.
public struct BetaFederationIssuer: Codable, Hashable, Sendable {
    /// Tagged ID of the federation issuer.
    public var id: String
    /// If set, all rules referencing this issuer reject token exchange.
    public var archivedAt: Date?
    /// Tagged ID (`user_`/`svac_`) of the actor that archived this issuer.
    public var archivedByActorID: String?
    /// Whether the jwt-bearer exchange enforces JTI single-use (replay protection) for
    /// tokens from this issuer. Applies only to assertions carrying a `jti` claim;
    /// tokens without one are accepted without single-use enforcement.
    public var checkJti: Bool
    /// When this issuer was created.
    public var createdAt: Date
    /// Tagged ID (`user_`/`svac_`) of the actor that created this issuer.
    public var createdByActorID: String?
    /// The `iss` claim value. Incoming JWTs must match exactly.
    public var issuerURL: String
    /// How signing keys are obtained for signature verification.
    public var jwks: BetaFederationIssuer.JWKS
    /// If set, Anthropic's JWKS poller has paused polling for this issuer after
    /// repeated fetch failures. Re-enable by sending `jwks_polling_disabled: false` via
    /// the issuer update endpoint (POST) once the upstream JWKS endpoint is fixed. An
    /// OAuth caller cannot send this when the issuer backs a rule with any scope other
    /// than `workspace:developer` or `workspace:inference`; use a Console session.
    public var jwksPollingDisabledAt: Date?
    /// Maximum allowed iat→exp spread for assertions from this issuer (1-176400
    /// seconds, i.e. up to 49h). Assertions must carry both `iat` and `exp`; a missing
    /// `iat` is rejected.
    public var maxJwtLifetimeSeconds: Int
    /// Admin-chosen slug identifier.
    public var name: String
    /// Live state of Anthropic's JWKS polling for this issuer.
    ///
    /// Populated on both single-issuer retrieval and list responses, including archived
    /// issuers. Typically null for inline-key issuers (no polling), or when poll status
    /// is temporarily unavailable or polling has not started yet.
    public var pollStatus: BetaFederationIssuerPollStatus?
    public var type: String
    /// When this issuer was last updated.
    public var updatedAt: Date
    /// Tagged ID (`user_`/`svac_`) of the actor that last updated this issuer.
    public var updatedByActorID: String?

    public init(id: String, archivedAt: Date? = nil, archivedByActorID: String? = nil, checkJti: Bool, createdAt: Date, createdByActorID: String? = nil, issuerURL: String, jwks: BetaFederationIssuer.JWKS, jwksPollingDisabledAt: Date? = nil, maxJwtLifetimeSeconds: Int, name: String, pollStatus: BetaFederationIssuerPollStatus? = nil, type: String = "federation_issuer", updatedAt: Date, updatedByActorID: String? = nil) {
        self.id = id
        self.archivedAt = archivedAt
        self.archivedByActorID = archivedByActorID
        self.checkJti = checkJti
        self.createdAt = createdAt
        self.createdByActorID = createdByActorID
        self.issuerURL = issuerURL
        self.jwks = jwks
        self.jwksPollingDisabledAt = jwksPollingDisabledAt
        self.maxJwtLifetimeSeconds = maxJwtLifetimeSeconds
        self.name = name
        self.pollStatus = pollStatus
        self.type = type
        self.updatedAt = updatedAt
        self.updatedByActorID = updatedByActorID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case archivedByActorID = "archived_by_actor_id"
        case checkJti = "check_jti"
        case createdAt = "created_at"
        case createdByActorID = "created_by_actor_id"
        case issuerURL = "issuer_url"
        case jwks
        case jwksPollingDisabledAt = "jwks_polling_disabled_at"
        case maxJwtLifetimeSeconds = "max_jwt_lifetime_seconds"
        case name
        case pollStatus = "poll_status"
        case type
        case updatedAt = "updated_at"
        case updatedByActorID = "updated_by_actor_id"
    }
}

extension BetaFederationIssuer {

    public indirect enum JWKS: Codable, Hashable, Sendable {
        case discovery(BetaJWKSDiscovery)
        case explicitUrl(BetaJWKSExplicitURL)
        case inline(BetaJWKSInline)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "discovery": self = .discovery(try BetaJWKSDiscovery(from: decoder))
            case "explicit_url": self = .explicitUrl(try BetaJWKSExplicitURL(from: decoder))
            case "inline": self = .inline(try BetaJWKSInline(from: decoder))
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
