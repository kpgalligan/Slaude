// Transformed from `anthropic.types.beta.beta_managed_agents_effort_high` (beta_managed_agents_effort_high.py).

import Foundation

/// High effort. Favors reasoning depth.
public struct BetaManagedAgentsEffortHigh: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "high") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
