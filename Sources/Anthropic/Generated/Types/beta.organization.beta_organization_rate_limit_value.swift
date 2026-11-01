// Transformed from `anthropic.types.beta.organization.beta_organization_rate_limit_value` (beta_organization_rate_limit_value.py).

import Foundation

public struct BetaOrganizationRateLimitValue: Codable, Hashable, Sendable {
    /// The limiter type (for example, `requests_per_minute` or
    /// `input_tokens_per_minute`).
    public var type: String
    /// The configured limit value for this limiter type.
    public var value: Int

    public init(type: String, value: Int) {
        self.type = type
        self.value = value
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
}
