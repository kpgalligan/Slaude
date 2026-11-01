// Transformed from `anthropic.types.beta.beta_managed_agents_custom_skill` (beta_managed_agents_custom_skill.py).

import Foundation

/// A resolved user-created custom skill.
public struct BetaManagedAgentsCustomSkill: Codable, Hashable, Sendable {
    public var skillId: String
    public var type: String
    public var version: String

    public init(skillId: String, type: String = "custom", version: String) {
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
