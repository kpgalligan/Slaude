// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_self_params` (beta_managed_agents_multiagent_self_params.py).

import Foundation

/// Sentinel roster entry meaning "the agent that owns this configuration".
///
/// Resolved server-side to a concrete agent reference.
public struct BetaManagedAgentsMultiagentSelfParams: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "self") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
