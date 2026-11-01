// Transformed from `anthropic.types.beta.beta_managed_agents_skill_not_found_run_error` (beta_managed_agents_skill_not_found_run_error.py).

import Foundation

/// A skill referenced by the deployment's agent no longer exists.
public struct BetaManagedAgentsSkillNotFoundRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "skill_not_found_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
