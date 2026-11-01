// Transformed from `anthropic.types.organization.federation.service_account_target` (service_account_target.py).

import Foundation

/// Bind to a fixed service account by ID.
public struct ServiceAccountTarget: Codable, Hashable, Sendable {
    /// Tagged ID of the service account to mint tokens for.
    public var serviceAccountId: String
    public var type: String
    /// Service account's display name at read time. Ignored on writes.
    public var serviceAccountName: String?

    public init(serviceAccountId: String, type: String = "service_account", serviceAccountName: String? = nil) {
        self.serviceAccountId = serviceAccountId
        self.type = type
        self.serviceAccountName = serviceAccountName
    }

    enum CodingKeys: String, CodingKey {
        case serviceAccountId = "service_account_id"
        case type
        case serviceAccountName = "service_account_name"
    }
}
