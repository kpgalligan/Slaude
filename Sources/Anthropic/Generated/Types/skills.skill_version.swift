// Transformed from `anthropic.types.skills.skill_version` (skill_version.py).

import Foundation

public struct SkillVersion: Codable, Hashable, Sendable {
    /// Unique identifier for this Skill Version.
    ///
    /// The id addresses the version in paths and pins it in references.
    public var id: String
    /// ISO 8601 timestamp of when the skill was created.
    public var createdAt: Date
    /// Description of the skill version.
    ///
    /// This is extracted from the SKILL.md file in the skill upload.
    public var description: String
    /// The Skill's immutable kebab-case slug, set at creation from the first upload's
    /// SKILL.md frontmatter `name` (or its enclosing directory). Every later upload
    /// must resolve to the same value. Also the top-level directory of the Skill's
    /// mounted files and the base name of a downloaded archive.
    public var name: String
    /// Unique identifier for the skill.
    ///
    /// The format and length of IDs may change over time.
    public var skillID: String
    /// Object type.
    ///
    /// For Skill Versions, this is always `"skill_version"`.
    public var type: String

    public init(id: String, createdAt: Date, description: String, name: String, skillID: String, type: String = "skill_version") {
        self.id = id
        self.createdAt = createdAt
        self.description = description
        self.name = name
        self.skillID = skillID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case description
        case name
        case skillID = "skill_id"
        case type
    }
}
