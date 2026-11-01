// Transformed from `anthropic.types.beta.skills.beta_deleted_skill_version` (beta_deleted_skill_version.py).

import Foundation

public struct BetaDeletedSkillVersion: Codable, Hashable, Sendable {
    /// Unique identifier for this Skill Version.
    ///
    /// The id addresses the version in paths and pins it in references.
    public var id: String
    /// Deleted object type.
    ///
    /// For Skill Versions, this is always `"skill_version_deleted"`.
    public var type: String

    public init(id: String, type: String = "skill_version_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
