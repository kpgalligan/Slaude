// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_redacted_block` (beta_managed_agents_redacted_block.py).

import Foundation

/// Placeholder for content withheld by Anthropic model policy.
public struct BetaManagedAgentsRedactedBlock: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "redacted") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
