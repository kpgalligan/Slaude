// Transformed from `anthropic.types.beta.organization.beta_analytics_service_account_actor` (beta_analytics_service_account_actor.py).

import Foundation

public struct BetaAnalyticsServiceAccountActor: Codable, Hashable, Sendable {
    /// Tagged service account ID.
    public var serviceAccountID: String
    public var type: String

    public init(serviceAccountID: String, type: String = "service_account_actor") {
        self.serviceAccountID = serviceAccountID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case serviceAccountID = "service_account_id"
        case type
    }
}
