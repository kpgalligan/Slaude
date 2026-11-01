// Transformed from `anthropic.types.beta.organization.beta_spend_limit_organization_scope_param` (beta_spend_limit_organization_scope_param.py).

import Foundation

public struct BetaSpendLimitOrganizationScopeParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "organization") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
