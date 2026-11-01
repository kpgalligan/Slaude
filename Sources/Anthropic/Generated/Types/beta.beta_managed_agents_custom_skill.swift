// Transformed from `anthropic.types.beta.beta_managed_agents_custom_skill` (beta_managed_agents_custom_skill.py).

import Foundation

/// A resolved user-created custom skill.
public struct BetaManagedAgentsCustomSkill: Codable, Hashable, Sendable {
    public var skillID: String
    public var type: String
    public var version: String

    public init(skillID: String, type: String = "custom", version: String) {
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
