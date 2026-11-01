// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_advisor_enabled_params` (beta_managed_agents_multiagent_advisor_enabled_params.py).

import Foundation

/// The session's primary thread can consult `model` mid-turn.
public struct BetaManagedAgentsMultiagentAdvisorEnabledParams: Codable, Hashable, Sendable {
    /// A Claude model id.
    ///
    /// The model must be permitted as an advisor for this agent's model.
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
