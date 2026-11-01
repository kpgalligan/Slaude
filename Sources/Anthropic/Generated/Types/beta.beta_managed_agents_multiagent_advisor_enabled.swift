// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_advisor_enabled` (beta_managed_agents_multiagent_advisor_enabled.py).

import Foundation

/// The session's primary thread can consult `model` mid-turn.
public struct BetaManagedAgentsMultiagentAdvisorEnabled: Codable, Hashable, Sendable {
    /// The advisor model id.
    public var model: String
    public var type: String

    public init(model: String, type: String = "enabled") {
        self.model = model
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case model
        case type
    }
}
