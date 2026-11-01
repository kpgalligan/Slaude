// Transformed from `anthropic.types.beta.organization.beta_spend_limit` (beta_spend_limit.py).

import Foundation

/// A configured spend limit: a cap on metered spend for one scope and period.
public struct BetaSpendLimit: Codable, Hashable, Sendable {
    /// Unique tagged ID of the spend limit (`spl_...`).
    public var id: String
    /// Limit amount as a non-negative integer decimal string in the minor unit of
    /// `currency` (cents for USD): "50000" is $500.00. `null` means no numeric cap is
    /// configured at this scope — see the effective report for whether a limit applies.
    public var amount: String?
    /// RFC 3339 datetime at which the spend limit was created.
    public var createdAt: Date
    /// ISO 4217 code of the organization's billing currency; the unit for `amount`.
    public var currency: String
    /// Read-only.
    ///
    /// `false` when extra usage is switched off for this organization (`organization`
    /// limit); `amount` is kept and applies again when it's switched back on. Always
    /// `true` for other limits.
    public var isEnabled: Bool
    /// Length of the window the limit resets over.
    ///
    /// `amount` caps spend within each period.
    public var period: BetaSpendLimitPeriod
    /// What the limit applies to.
    ///
    /// A tagged union on `type`; each variant carries the identifier for its scope.
    public var scope: BetaSpendLimit.Scope
    /// Object type. Always `spend_limit`.
    public var type: String
    /// RFC 3339 datetime at which the spend limit was last modified.
    public var updatedAt: Date

    public init(id: String, amount: String? = nil, createdAt: Date, currency: String, isEnabled: Bool, period: BetaSpendLimitPeriod, scope: BetaSpendLimit.Scope, type: String = "spend_limit", updatedAt: Date) {
        self.id = id
        self.amount = amount
        self.createdAt = createdAt
        self.currency = currency
        self.isEnabled = isEnabled
        self.period = period
        self.scope = scope
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case createdAt = "created_at"
        case currency
        case isEnabled = "is_enabled"
        case period
        case scope
        case type
        case updatedAt = "updated_at"
    }
}

extension BetaSpendLimit {

    public indirect enum Scope: Codable, Hashable, Sendable {
        case user(BetaSpendLimitUserScope)
        case seatTier(BetaSpendLimitSeatTierScope)
        case rbacGroup(BetaSpendLimitRBACGroupScope)
        case organizationService(BetaSpendLimitOrganizationServiceScope)
        case organization(BetaSpendLimitOrganizationScope)
        case workspace(BetaSpendLimitWorkspaceScope)
        case usageTier(BetaSpendLimitUsageTierScope)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "user": self = .user(try BetaSpendLimitUserScope(from: decoder))
            case "seat_tier": self = .seatTier(try BetaSpendLimitSeatTierScope(from: decoder))
            case "rbac_group": self = .rbacGroup(try BetaSpendLimitRBACGroupScope(from: decoder))
            case "organization_service": self = .organizationService(try BetaSpendLimitOrganizationServiceScope(from: decoder))
            case "organization": self = .organization(try BetaSpendLimitOrganizationScope(from: decoder))
            case "workspace": self = .workspace(try BetaSpendLimitWorkspaceScope(from: decoder))
            case "usage_tier": self = .usageTier(try BetaSpendLimitUsageTierScope(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .user(let v): try v.encode(to: encoder)
            case .seatTier(let v): try v.encode(to: encoder)
            case .rbacGroup(let v): try v.encode(to: encoder)
            case .organizationService(let v): try v.encode(to: encoder)
            case .organization(let v): try v.encode(to: encoder)
            case .workspace(let v): try v.encode(to: encoder)
            case .usageTier(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
