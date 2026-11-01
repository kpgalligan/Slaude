// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_user_actor` (beta_managed_agents_user_actor.py).

import Foundation

/// A human user, for example acting through the Anthropic Console.
public struct BetaManagedAgentsUserActor: Codable, Hashable, Sendable {
    public var type: String
    /// ID of the user (a `user_...` value).
    public var userId: String

    public init(type: String = "user_actor", userId: String) {
        self.type = type
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userId = "user_id"
    }
}
