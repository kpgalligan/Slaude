// Transformed from `anthropic.types.beta.beta_container` (beta_container.py).

import Foundation

/// Information about the container used in the request (for the code execution tool)
public struct BetaContainer: Codable, Hashable, Sendable {
    /// Identifier for the container used in this request
    public var id: String
    /// The time at which the container will expire.
    public var expiresAt: Date
    /// Skills loaded in the container
    public var skills: [BetaContainerSkill]?

    public init(id: String, expiresAt: Date, skills: [BetaContainerSkill]? = nil) {
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
