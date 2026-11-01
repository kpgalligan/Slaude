// Transformed from `anthropic.types.beta.beta_managed_agents_effort_low_param` (beta_managed_agents_effort_low_param.py).

import Foundation

/// Low effort. Favors latency over reasoning depth.
public struct BetaManagedAgentsEffortLowParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "low") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
