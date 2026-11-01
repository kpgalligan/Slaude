// Transformed from `anthropic.types.beta.beta_webhook_session_thread_created_event_data` (beta_webhook_session_thread_created_event_data.py).

import Foundation

public struct BetaWebhookSessionThreadCreatedEventData: Codable, Hashable, Sendable {
    /// ID of the session that triggered the event.
    public var id: String
    public var organizationId: String
    /// ID of the session thread this event refers to.
    public var sessionThreadId: String
    public var type: String
    public var workspaceId: String

    public init(id: String, organizationId: String, sessionThreadId: String, type: String = "session.thread_created", workspaceId: String) {
        self.id = id
        self.organizationId = organizationId
        self.sessionThreadId = sessionThreadId
        self.type = type
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case sessionThreadId = "session_thread_id"
        case type
        case workspaceId = "workspace_id"
    }
}
