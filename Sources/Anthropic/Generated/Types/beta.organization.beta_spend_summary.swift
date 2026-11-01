// Transformed from `anthropic.types.beta.organization.beta_spend_summary` (beta_spend_summary.py).

import Foundation

/// Per-member effective-limit report row (`GET /spend_limits/effective`).
public struct BetaSpendSummary: Codable, Hashable, Sendable {
    public var actor: BetaSpendSummary.Actor
    /// Effective limit amount as a non-negative integer decimal string in the minor
    /// unit of `currency` (cents for USD). `null` means no limit applies for this row's
    /// `period` — each period resolves independently, so another period may still cap
    /// this member.
    public var amount: String?
    /// ISO 4217 code of the organization's billing currency; the unit for `amount` and
    /// `period_to_date_spend`.
    public var currency: String
    /// Period this row's effective limit and spend are reported for.
    public var period: BetaSpendLimitPeriod
    /// The member's spend so far in the current period, as a non-negative decimal
    /// string in the minor unit of `currency` (cents for USD). May carry fractional
    /// minor units up to three decimal places (e.g. `"12050.5"`) — metered usage is not
    /// rounded to whole cents. Reads as `"0"` when the spend reading is temporarily
    /// unavailable.
    public var periodToDateSpend: String
    public var scope: BetaSpendSummary.Scope
    public var source: BetaSpendSummary.Source
    public var spendLimitID: String

    public init(actor: BetaSpendSummary.Actor, amount: String? = nil, currency: String, period: BetaSpendLimitPeriod, periodToDateSpend: String, scope: BetaSpendSummary.Scope, source: BetaSpendSummary.Source, spendLimitID: String) {
        self.actor = actor
        self.amount = amount
        self.currency = currency
        self.period = period
        self.periodToDateSpend = periodToDateSpend
        self.scope = scope
        self.source = source
        self.spendLimitID = spendLimitID
    }

    enum CodingKeys: String, CodingKey {
        case actor
        case amount
        case currency
        case period
        case periodToDateSpend = "period_to_date_spend"
        case scope
        case source
        case spendLimitID = "spend_limit_id"
    }
}

extension BetaSpendSummary {

    public indirect enum Actor: Codable, Hashable, Sendable {
        case userActor(BetaSpendLimitUserActor)
        case scopedApiKeyActor(BetaSpendLimitScopedAPIKeyActor)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "user_actor": self = .userActor(try BetaSpendLimitUserActor(from: decoder))
            case "scoped_api_key_actor": self = .scopedApiKeyActor(try BetaSpendLimitScopedAPIKeyActor(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .userActor(let v): try v.encode(to: encoder)
            case .scopedApiKeyActor(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

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

    public indirect enum Source: Codable, Hashable, Sendable {
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
