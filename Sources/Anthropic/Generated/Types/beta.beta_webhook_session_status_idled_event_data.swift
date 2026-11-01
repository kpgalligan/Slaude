// Transformed from `anthropic.types.beta.beta_webhook_session_status_idled_event_data` (beta_webhook_session_status_idled_event_data.py).

import Foundation

public struct BetaWebhookSessionStatusIdledEventData: Codable, Hashable, Sendable {
    /// ID of the session that triggered the event.
    public var id: String
    public var organizationId: String
    public var type: String
    public var workspaceId: String

    public init(id: String, organizationId: String, type: String = "session.status_idled", workspaceId: String) {
        self.id = id
        self.organizationId = organizationId
        self.type = type
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case type
        case workspaceId = "workspace_id"
    }
}
