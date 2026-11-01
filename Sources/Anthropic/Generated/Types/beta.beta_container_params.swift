// Transformed from `anthropic.types.beta.beta_container_params` (beta_container_params.py).

import Foundation

/// Container parameters with skills to be loaded.
public struct BetaContainerParams: Codable, Hashable, Sendable {
    /// Container id
    public var id: String??
    /// List of skills to load in the container
    public var skills: [BetaSkillParams]??

    public init(id: String?? = nil, skills: [BetaSkillParams]?? = nil) {
        self.id = id
        self.skills = skills
    }

    enum CodingKeys: String, CodingKey {
        case id
        case skills
    }
}
