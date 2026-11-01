// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_user_tool_confirmation_event` (beta_managed_agents_user_tool_confirmation_event.py).

import Foundation

/// A tool confirmation event that approves or denies a pending tool execution.
public struct BetaManagedAgentsUserToolConfirmationEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// The confirmation result: 'allow' or 'deny'.
    public var result: Result
    /// The id of the `agent.tool_use` or `agent.mcp_tool_use` event this result
    /// corresponds to, which can be found in the last `session.status_idle`
    /// [event's](https://platform.claude.com/docs/en/api/beta/sessions/events/list#beta_managed_agents_session_requires_action.event_ids)
    /// `stop_reason.event_ids` field.
    public var toolUseId: String
    public var type: String
    /// Optional message providing context for a 'deny' decision.
    ///
    /// Only allowed when result is 'deny'.
    public var denyMessage: String?
    /// Timestamp when the confirmation was processed.
    public var processedAt: Date?
    /// Set by the server to the subagent thread this confirmation was routed to.
    ///
    /// Omitted when it was routed to the primary thread.
    public var sessionThreadId: String?

    public init(id: String, result: Result, toolUseId: String, type: String = "user.tool_confirmation", denyMessage: String? = nil, processedAt: Date? = nil, sessionThreadId: String? = nil) {
        self.id = id
        self.result = result
        self.toolUseId = toolUseId
        self.type = type
        self.denyMessage = denyMessage
        self.processedAt = processedAt
        self.sessionThreadId = sessionThreadId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case result
        case toolUseId = "tool_use_id"
        case type
        case denyMessage = "deny_message"
        case processedAt = "processed_at"
        case sessionThreadId = "session_thread_id"
    }

    public enum Result: OpenEnum, CaseIterable {
        case allow
        case deny
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Result] = [.allow, .deny]

        public init(rawValue: String) {
            switch rawValue {
            case "allow": self = .allow
            case "deny": self = .deny
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .allow: return "allow"
            case .deny: return "deny"
            case .unknown(let value): return value
            }
        }
    }
}
