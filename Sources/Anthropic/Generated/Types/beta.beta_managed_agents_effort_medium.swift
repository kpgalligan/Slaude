// Transformed from `anthropic.types.beta.beta_managed_agents_effort_medium` (beta_managed_agents_effort_medium.py).

import Foundation

/// Medium effort. Balances latency and reasoning depth.
public struct BetaManagedAgentsEffortMedium: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "medium") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
