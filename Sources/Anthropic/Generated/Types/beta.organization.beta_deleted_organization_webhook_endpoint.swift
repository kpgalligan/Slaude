// Transformed from `anthropic.types.beta.organization.beta_deleted_organization_webhook_endpoint` (beta_deleted_organization_webhook_endpoint.py).

import Foundation

/// A deleted organization webhook endpoint.
public struct BetaDeletedOrganizationWebhookEndpoint: Codable, Hashable, Sendable {
    /// ID of the deleted webhook endpoint.
    public var id: String
    /// Always `webhook_endpoint_deleted`.
    public var type: String

    public init(id: String, type: String = "webhook_endpoint_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
