// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_delete_session_resource` (beta_managed_agents_delete_session_resource.py).

import Foundation

/// Confirmation of resource deletion.
public struct BetaManagedAgentsDeleteSessionResource: Codable, Hashable, Sendable {
    public var id: String
    public var type: String

    public init(id: String, type: String = "session_resource_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
