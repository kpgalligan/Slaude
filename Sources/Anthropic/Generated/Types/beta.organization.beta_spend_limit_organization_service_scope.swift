// Transformed from `anthropic.types.beta.organization.beta_spend_limit_organization_service_scope` (beta_spend_limit_organization_service_scope.py).

import Foundation

public struct BetaSpendLimitOrganizationServiceScope: Codable, Hashable, Sendable {
    public var service: String
    public var type: String

    public init(service: String, type: String = "organization_service") {
        self.service = service
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case service
        case type
    }
}
