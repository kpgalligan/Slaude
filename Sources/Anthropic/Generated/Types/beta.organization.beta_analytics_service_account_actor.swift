// Transformed from `anthropic.types.beta.organization.beta_analytics_service_account_actor` (beta_analytics_service_account_actor.py).

import Foundation

public struct BetaAnalyticsServiceAccountActor: Codable, Hashable, Sendable {
    /// Tagged service account ID.
    public var serviceAccountId: String
    public var type: String

    public init(serviceAccountId: String, type: String = "service_account_actor") {
        self.serviceAccountId = serviceAccountId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case serviceAccountId = "service_account_id"
        case type
    }
}
