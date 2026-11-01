// Transformed from `anthropic.types.beta.organization.spend_limits.increase_request_approve_response` (increase_request_approve_response.py).

import Foundation

public struct IncreaseRequestApproveResponse: Codable, Hashable, Sendable {
    public var id: String
    public var actor: IncreaseRequestApproveResponse.Actor
    public var createdAt: Date
    public var period: BetaSpendLimitPeriod
    public var resolvedAt: Date?
    public var resolvedBy: IncreaseRequestApproveResponse.ResolvedBy?
    /// A configured spend limit: a cap on metered spend for one scope and period.
    public var spendLimit: BetaSpendLimit
    /// Per-member effective-limit report row (`GET /spend_limits/effective`).
    public var spendSummary: BetaSpendSummary?
    public var status: BetaSpendLimitIncreaseRequestStatus
    public var type: String

    public init(id: String, actor: IncreaseRequestApproveResponse.Actor, createdAt: Date, period: BetaSpendLimitPeriod, resolvedAt: Date? = nil, resolvedBy: IncreaseRequestApproveResponse.ResolvedBy? = nil, spendLimit: BetaSpendLimit, spendSummary: BetaSpendSummary? = nil, status: BetaSpendLimitIncreaseRequestStatus, type: String = "spend_limit_increase_request") {
        self.id = id
        self.actor = actor
        self.createdAt = createdAt
        self.period = period
        self.resolvedAt = resolvedAt
        self.resolvedBy = resolvedBy
        self.spendLimit = spendLimit
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
        case spendLimit = "spend_limit"
        case spendSummary = "spend_summary"
        case status
        case type
    }
}

extension IncreaseRequestApproveResponse {

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
