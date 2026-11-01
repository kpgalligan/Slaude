// Transformed from `anthropic.types.beta.organization.beta_api_key_service_account_actor` (beta_api_key_service_account_actor.py).

import Foundation

public struct BetaAPIKeyServiceAccountActor: Codable, Hashable, Sendable {
    /// ID of the Service Account the API key acts as.
    public var serviceAccountId: String
    /// Principal type. Always `"service_account_actor"` for a Service Account.
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
