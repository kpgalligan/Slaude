// Transformed from `anthropic.types.beta.beta_managed_agents_anthropic_skill` (beta_managed_agents_anthropic_skill.py).

import Foundation

/// A resolved Anthropic-managed skill.
public struct BetaManagedAgentsAnthropicSkill: Codable, Hashable, Sendable {
    public var skillId: String
    public var type: String
    public var version: String

    public init(skillId: String, type: String = "anthropic", version: String) {
        self.skillId = skillId
        self.type = type
        self.version = version
    }

    enum CodingKeys: String, CodingKey {
        case skillId = "skill_id"
        case type
        case version
    }
}
