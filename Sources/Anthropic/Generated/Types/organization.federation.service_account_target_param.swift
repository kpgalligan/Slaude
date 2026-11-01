// Transformed from `anthropic.types.organization.federation.service_account_target_param` (service_account_target_param.py).

import Foundation

/// Bind to a fixed service account by ID.
public struct ServiceAccountTargetParam: Codable, Hashable, Sendable {
    /// Tagged ID of the service account to mint tokens for.
    public var serviceAccountID: String
    public var type: String
    /// Service account's display name at read time. Ignored on writes.
    public var serviceAccountName: String??

    public init(serviceAccountID: String, type: String = "service_account", serviceAccountName: String?? = nil) {
        self.serviceAccountID = serviceAccountID
        self.type = type
        self.serviceAccountName = serviceAccountName
    }

    enum CodingKeys: String, CodingKey {
        case serviceAccountID = "service_account_id"
        case type
        case serviceAccountName = "service_account_name"
    }
}
