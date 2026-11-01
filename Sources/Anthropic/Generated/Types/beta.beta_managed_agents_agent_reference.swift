// Transformed from `anthropic.types.beta.beta_managed_agents_agent_reference` (beta_managed_agents_agent_reference.py).

import Foundation

/// A resolved agent reference with a concrete version.
public struct BetaManagedAgentsAgentReference: Codable, Hashable, Sendable {
    public var id: String
    public var type: String
    public var version: Int

    public init(id: String, type: String = "agent", version: Int) {
        self.id = id
        self.type = type
        self.version = version
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case version
    }
}
