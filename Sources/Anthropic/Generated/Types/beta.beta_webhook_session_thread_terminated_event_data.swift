// Transformed from `anthropic.types.beta.beta_webhook_session_thread_terminated_event_data` (beta_webhook_session_thread_terminated_event_data.py).

import Foundation

public struct BetaWebhookSessionThreadTerminatedEventData: Codable, Hashable, Sendable {
    /// ID of the session that triggered the event.
    public var id: String
    public var organizationID: String
    /// ID of the session thread this event refers to.
    public var sessionThreadID: String
    public var type: String
    public var workspaceID: String

    public init(id: String, organizationID: String, sessionThreadID: String, type: String = "session.thread_terminated", workspaceID: String) {
        self.id = id
        self.organizationID = organizationID
        self.sessionThreadID = sessionThreadID
        self.type = type
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case organizationID = "organization_id"
        case sessionThreadID = "session_thread_id"
        case type
        case workspaceID = "workspace_id"
    }
}
