// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_requires_action` (beta_managed_agents_session_requires_action.py).

import Foundation

/// The agent is idle waiting on one or more blocking user-input events (tool confirmation, custom tool result, etc.). Resolving all of them transitions the session back to running.
public struct BetaManagedAgentsSessionRequiresAction: Codable, Hashable, Sendable {
    /// The ids of events the agent is blocked on.
    ///
    /// Resolving fewer than all re-emits `session.status_idle` with the remainder.
    public var eventIds: [String]
    public var type: String

    public init(eventIds: [String], type: String = "requires_action") {
        self.eventIds = eventIds
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case eventIds = "event_ids"
        case type
    }
}
