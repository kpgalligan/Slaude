// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_custom_tool_use_event` (beta_managed_agents_agent_custom_tool_use_event.py).

import Foundation

/// Event emitted when the agent calls a custom tool.
///
/// The session goes idle until the client sends a `user.custom_tool_result` event with the result. The client can send it as soon as this event arrives, without waiting for `session.status_idle`.
public struct BetaManagedAgentsAgentCustomToolUseEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Input parameters for the tool call.
    public var input: [String: JSONValue]
    /// Name of the custom tool being called.
    public var name: String
    /// Timestamp when this tool use was processed.
    public var processedAt: Date
    public var type: String
    /// When set, this event was cross-posted from a subagent's thread to surface its
    /// custom tool use on the primary thread's stream. Empty on the thread's own
    /// events. Informational only: the server routes the matching
    /// `user.custom_tool_result` by `custom_tool_use_id`, so clients do not send it
    /// back.
    public var sessionThreadId: String?

    public init(id: String, input: [String: JSONValue], name: String, processedAt: Date, type: String = "agent.custom_tool_use", sessionThreadId: String? = nil) {
        self.id = id
        self.input = input
        self.name = name
        self.processedAt = processedAt
        self.type = type
        self.sessionThreadId = sessionThreadId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case input
        case name
        case processedAt = "processed_at"
        case type
        case sessionThreadId = "session_thread_id"
    }
}
