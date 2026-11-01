// Transformed from `anthropic.types.beta.beta_webhook_memory_store_created_event_data` (beta_webhook_memory_store_created_event_data.py).

import Foundation

public struct BetaWebhookMemoryStoreCreatedEventData: Codable, Hashable, Sendable {
    /// ID of the memory store that triggered the event.
    public var id: String
    public var organizationID: String
    public var type: String
    public var workspaceID: String

    public init(id: String, organizationID: String, type: String = "memory_store.created", workspaceID: String) {
        self.id = id
        self.organizationID = organizationID
        self.type = type
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case organizationID = "organization_id"
        case type
        case workspaceID = "workspace_id"
    }
}
