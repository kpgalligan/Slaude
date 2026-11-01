// Transformed from `anthropic.types.beta.beta_managed_agents_effort_max` (beta_managed_agents_effort_max.py).

import Foundation

/// Maximum effort. Favors reasoning depth over latency.
public struct BetaManagedAgentsEffortMax: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "max") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
