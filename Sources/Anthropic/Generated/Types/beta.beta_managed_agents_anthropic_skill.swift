// Transformed from `anthropic.types.beta.beta_managed_agents_anthropic_skill` (beta_managed_agents_anthropic_skill.py).

import Foundation

/// A resolved Anthropic-managed skill.
public struct BetaManagedAgentsAnthropicSkill: Codable, Hashable, Sendable {
    public var skillID: String
    public var type: String
    public var version: String

    public init(skillID: String, type: String = "anthropic", version: String) {
        self.skillID = skillID
        self.type = type
        self.version = version
    }

    enum CodingKeys: String, CodingKey {
        case skillID = "skill_id"
        case type
        case version
    }
}
