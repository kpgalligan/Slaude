// Transformed from `anthropic.types.beta.beta_managed_agents_deleted_session` (beta_managed_agents_deleted_session.py).

import Foundation

/// Confirmation that a `session` has been permanently deleted.
public struct BetaManagedAgentsDeletedSession: Codable, Hashable, Sendable {
    public var id: String
    public var type: String

    public init(id: String, type: String = "session_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
