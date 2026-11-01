// Transformed from `anthropic.types.container_params` (container_params.py).

import Foundation

/// Container parameters with skills to be loaded.
public struct ContainerParams: Codable, Hashable, Sendable {
    /// Container id
    public var id: String??
    /// List of skills to load in the container
    public var skills: [SkillParams]??

    public init(id: String?? = nil, skills: [SkillParams]?? = nil) {
        self.id = id
        self.skills = skills
    }

    enum CodingKeys: String, CodingKey {
        case id
        case skills
    }
}
