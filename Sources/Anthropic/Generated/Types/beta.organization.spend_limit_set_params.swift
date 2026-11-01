// Transformed from `anthropic.types.beta.organization.spend_limit_set_params` (spend_limit_set_params.py).

import Foundation

public struct SpendLimitSetParams: Codable, Hashable, Sendable {
    /// Limit amount as a non-negative integer decimal string in the minor unit of the
    /// organization's billing currency (cents for USD): "50000" is $500.00. `null` sets
    /// an explicit no-limit override for this scope and `period` only — each period
    /// resolves independently, so caps for other periods still apply.
    public var amount: String?
    /// What the limit applies to.
    ///
    /// Claude Enterprise organizations set `user` limits. Claude Console organizations
    /// set `organization` and `workspace` limits. Any other combination returns 400.
    /// Setting `organization` and `workspace` limits through the API is in an early
    /// access preview. To request access, contact your Anthropic account team.
    public var scope: SpendLimitSetParams.Scope
    public var period: BetaSpendLimitPeriod?
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(amount: String? = nil, scope: SpendLimitSetParams.Scope, period: BetaSpendLimitPeriod? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.amount = amount
        self.scope = scope
        self.period = period
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case amount
        case scope
        case period
        case betas
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(amount, forKey: .amount)
        try c.encode(scope, forKey: .scope)
        try c.encodeIfPresent(period, forKey: .period)
        try c.encodeIfPresent(betas, forKey: .betas)
    }
}

extension SpendLimitSetParams {

    public indirect enum Scope: Codable, Hashable, Sendable {
        case user(BetaSpendLimitUserScopeParam)
        case organization(BetaSpendLimitOrganizationScopeParam)
        case workspace(BetaSpendLimitWorkspaceScopeParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "user": self = .user(try BetaSpendLimitUserScopeParam(from: decoder))
            case "organization": self = .organization(try BetaSpendLimitOrganizationScopeParam(from: decoder))
            case "workspace": self = .workspace(try BetaSpendLimitWorkspaceScopeParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .user(let v): try v.encode(to: encoder)
            case .organization(let v): try v.encode(to: encoder)
            case .workspace(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
