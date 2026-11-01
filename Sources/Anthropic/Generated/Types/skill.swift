// Transformed from `anthropic.types.skill` (skill.py).

import Foundation

public struct Skill: Codable, Hashable, Sendable {
    /// Unique identifier for the skill.
    ///
    /// The format and length of IDs may change over time.
    public var id: String
    /// ISO 8601 timestamp of when the skill was created.
    public var createdAt: Date
    /// Human-readable, single-line label for the Skill.
    ///
    /// Maximum 255 characters. Always set: derived from the SKILL.md frontmatter `name`
    /// when omitted at creation. Not unique.
    public var displayName: String
    /// ID of the newest Skill Version — what `latest` references resolve to.
    ///
    /// Always set: a Skill holds at least one version.
    public var latestVersionID: String
    /// Where the Skill comes from.
    ///
    /// Possible values:
    ///
    /// - `"custom"`: authored by the platform user; private to their workspace
    /// - `"anthropic"`: published by Anthropic; shared and read-only
    /// - `"anthropic_example"`: Anthropic-published sample Skill
    /// - `"plugin"`: resolved from an installed plugin
    public var source: SkillSource
    /// Object type.
    ///
    /// For Skills, this is always `"skill"`.
    public var type: String
    /// ISO 8601 timestamp of when the skill was last updated.
    public var updatedAt: Date

    public init(id: String, createdAt: Date, displayName: String, latestVersionID: String, source: SkillSource, type: String = "skill", updatedAt: Date) {
        self.id = id
        self.createdAt = createdAt
        self.displayName = displayName
        self.latestVersionID = latestVersionID
        self.source = source
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case displayName = "display_name"
        case latestVersionID = "latest_version_id"
        case source
        case type
        case updatedAt = "updated_at"
    }
}
