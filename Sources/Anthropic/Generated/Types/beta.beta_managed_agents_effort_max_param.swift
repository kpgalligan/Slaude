// Transformed from `anthropic.types.beta.beta_managed_agents_effort_max_param` (beta_managed_agents_effort_max_param.py).

import Foundation

/// Maximum effort. Favors reasoning depth over latency.
public struct BetaManagedAgentsEffortMaxParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "max") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
