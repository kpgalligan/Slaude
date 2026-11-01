// Transformed from `anthropic.types.beta.beta_managed_agents_anthropic_skill_params` (beta_managed_agents_anthropic_skill_params.py).

import Foundation

/// An Anthropic-managed skill.
public struct BetaManagedAgentsAnthropicSkillParams: Codable, Hashable, Sendable {
    /// Identifier of the Anthropic skill (e.g., "xlsx").
    public var skillID: String
    public var type: String
    /// Version to pin. Defaults to latest if omitted.
    public var version: String??

    public init(skillID: String, type: String = "anthropic", version: String?? = nil) {
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
