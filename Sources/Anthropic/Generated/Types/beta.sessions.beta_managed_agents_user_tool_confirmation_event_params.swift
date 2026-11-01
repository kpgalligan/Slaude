// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_user_tool_confirmation_event_params` (beta_managed_agents_user_tool_confirmation_event_params.py).

import Foundation

/// Parameters for confirming or denying a tool execution request.
public struct BetaManagedAgentsUserToolConfirmationEventParams: Codable, Hashable, Sendable {
    /// The confirmation result: 'allow' or 'deny'.
    public var result: Result
    /// The id of the `agent.tool_use` or `agent.mcp_tool_use` event this result
    /// corresponds to, which can be found in the last `session.status_idle`
    /// [event's](https://platform.claude.com/docs/en/api/beta/sessions/events/list#beta_managed_agents_session_requires_action.event_ids)
    /// `stop_reason.event_ids` field.
    public var toolUseID: String
    public var type: String
    /// Optional message providing context for a 'deny' decision.
    ///
    /// Only allowed when result is 'deny'.
    public var denyMessage: String??

    public init(result: Result, toolUseID: String, type: String = "user.tool_confirmation", denyMessage: String?? = nil) {
        self.result = result
        self.toolUseID = toolUseID
        self.type = type
        self.denyMessage = denyMessage
    }

    enum CodingKeys: String, CodingKey {
        case result
        case toolUseID = "tool_use_id"
        case type
        case denyMessage = "deny_message"
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
