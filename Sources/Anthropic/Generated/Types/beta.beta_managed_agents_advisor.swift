// Transformed from `anthropic.types.beta.beta_managed_agents_advisor` (beta_managed_agents_advisor.py).

import Foundation

/// Platform advisor roster entry: a model the session's primary thread may consult mid-turn.
public struct BetaManagedAgentsAdvisor: Codable, Hashable, Sendable {
    /// The advisor model id.
    public var model: String
    public var type: String

    public init(model: String, type: String = "advisor") {
        self.model = model
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case model
        case type
    }
}
