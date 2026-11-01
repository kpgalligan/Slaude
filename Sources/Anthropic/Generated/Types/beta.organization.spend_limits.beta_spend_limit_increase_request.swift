// Transformed from `anthropic.types.beta.organization.spend_limits.beta_spend_limit_increase_request` (beta_spend_limit_increase_request.py).

import Foundation

public struct BetaSpendLimitIncreaseRequest: Codable, Hashable, Sendable {
    public var id: String
    public var actor: BetaSpendLimitIncreaseRequest.Actor
    public var createdAt: Date
    public var period: BetaSpendLimitPeriod
    public var resolvedAt: Date?
    public var resolvedBy: BetaSpendLimitIncreaseRequest.ResolvedBy?
    /// Per-member effective-limit report row (`GET /spend_limits/effective`).
    public var spendSummary: BetaSpendSummary?
    public var status: BetaSpendLimitIncreaseRequestStatus
    public var type: String

    public init(id: String, actor: BetaSpendLimitIncreaseRequest.Actor, createdAt: Date, period: BetaSpendLimitPeriod, resolvedAt: Date? = nil, resolvedBy: BetaSpendLimitIncreaseRequest.ResolvedBy? = nil, spendSummary: BetaSpendSummary? = nil, status: BetaSpendLimitIncreaseRequestStatus, type: String = "spend_limit_increase_request") {
        self.id = id
        self.actor = actor
        self.createdAt = createdAt
        self.period = period
        self.resolvedAt = resolvedAt
        self.resolvedBy = resolvedBy
        self.spendSummary = spendSummary
        self.status = status
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case actor
        case createdAt = "created_at"
        case period
        case resolvedAt = "resolved_at"
        case resolvedBy = "resolved_by"
        case spendSummary = "spend_summary"
        case status
        case type
    }
}

extension BetaSpendLimitIncreaseRequest {

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

    public indirect enum ResolvedBy: Codable, Hashable, Sendable {
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
}
