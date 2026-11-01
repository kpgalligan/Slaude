// Transformed from `anthropic.types.beta.beta_managed_agents_custom_skill_params` (beta_managed_agents_custom_skill_params.py).

import Foundation

/// A user-created custom skill.
public struct BetaManagedAgentsCustomSkillParams: Codable, Hashable, Sendable {
    /// Tagged ID of the custom skill (e.g., "skill_01XJ5...").
    public var skillID: String
    public var type: String
    /// Version to pin. Defaults to latest if omitted.
    public var version: String??

    public init(skillID: String, type: String = "custom", version: String?? = nil) {
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
