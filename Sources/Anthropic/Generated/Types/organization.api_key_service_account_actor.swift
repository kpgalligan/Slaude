// Transformed from `anthropic.types.organization.api_key_service_account_actor` (api_key_service_account_actor.py).

import Foundation

public struct APIKeyServiceAccountActor: Codable, Hashable, Sendable {
    /// ID of the Service Account the API key acts as.
    public var serviceAccountID: String
    /// Principal type. Always `"service_account_actor"` for a Service Account.
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
