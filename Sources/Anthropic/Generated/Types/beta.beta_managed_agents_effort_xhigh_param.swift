// Transformed from `anthropic.types.beta.beta_managed_agents_effort_xhigh_param` (beta_managed_agents_effort_xhigh_param.py).

import Foundation

/// Extra-high effort. Not all models accept this level.
public struct BetaManagedAgentsEffortXhighParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "xhigh") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
