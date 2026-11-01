// Transformed from `anthropic.types.beta.beta_webhook_session_status_idled_event_data` (beta_webhook_session_status_idled_event_data.py).

import Foundation

public struct BetaWebhookSessionStatusIdledEventData: Codable, Hashable, Sendable {
    /// ID of the session that triggered the event.
    public var id: String
    public var organizationID: String
    public var type: String
    public var workspaceID: String

    public init(id: String, organizationID: String, type: String = "session.status_idled", workspaceID: String) {
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
