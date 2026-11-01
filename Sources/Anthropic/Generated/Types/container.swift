// Transformed from `anthropic.types.container` (container.py).

import Foundation

/// Information about the container used in the request (for the code execution tool)
public struct Container: Codable, Hashable, Sendable {
    /// Identifier for the container used in this request
    public var id: String
    /// The time at which the container will expire.
    public var expiresAt: Date
    /// Skills loaded in the container
    public var skills: [ContainerSkill]?

    public init(id: String, expiresAt: Date, skills: [ContainerSkill]? = nil) {
        self.id = id
        self.expiresAt = expiresAt
        self.skills = skills
    }

    enum CodingKeys: String, CodingKey {
        case id
        case expiresAt = "expires_at"
        case skills
    }
}
