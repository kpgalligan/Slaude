// Transformed from `anthropic.types.deleted_skill` (deleted_skill.py).

import Foundation

public struct DeletedSkill: Codable, Hashable, Sendable {
    /// Unique identifier for the skill.
    ///
    /// The format and length of IDs may change over time.
    public var id: String
    /// Deleted object type.
    ///
    /// For Skills, this is always `"skill_deleted"`.
    public var type: String

    public init(id: String, type: String = "skill_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
