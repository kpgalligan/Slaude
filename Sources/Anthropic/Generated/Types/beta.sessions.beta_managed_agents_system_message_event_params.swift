// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_system_message_event_params` (beta_managed_agents_system_message_event_params.py).

import Foundation

/// Privileged context for the accompanying turn and all subsequent turns, appended to the session's system context as a `role: "system"` turn rather than replacing the top-level system prompt. At most one per request: it must be the final event and immediately follow the `user.message`, `user.tool_result`, or `user.custom_tool_result` it accompanies. Only supported on models that accept mid-conversation system messages.
public struct BetaManagedAgentsSystemMessageEventParams: Codable, Hashable, Sendable {
    /// System content blocks to append. Text-only.
    public var content: [BetaManagedAgentsSystemContentBlockParam]
    public var type: String

    public init(content: [BetaManagedAgentsSystemContentBlockParam], type: String = "system.message") {
        self.content = content
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case type
    }
}
