// Transformed from `anthropic.types.beta.organization.beta_spend_limit_organization_scope` (beta_spend_limit_organization_scope.py).

import Foundation

public struct BetaSpendLimitOrganizationScope: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "organization") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
