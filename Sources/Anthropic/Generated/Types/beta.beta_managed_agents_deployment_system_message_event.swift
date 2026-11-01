// Transformed from `anthropic.types.beta.beta_managed_agents_deployment_system_message_event` (beta_managed_agents_deployment_system_message_event.py).

import Foundation

/// Privileged context for the accompanying turn and all subsequent turns, appended to the session's system context as a `role: "system"` turn rather than replacing the top-level system prompt.
public struct BetaManagedAgentsDeploymentSystemMessageEvent: Codable, Hashable, Sendable {
    /// System content blocks to append. Text-only.
    public var content: [BetaManagedAgentsSystemContentBlock]
    public var type: String

    public init(content: [BetaManagedAgentsSystemContentBlock], type: String = "system.message") {
        self.content = content
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case type
    }
}
