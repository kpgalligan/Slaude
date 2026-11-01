// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_redacted_block_param` (beta_managed_agents_redacted_block_param.py).

import Foundation

/// Placeholder for content withheld by Anthropic model policy.
public struct BetaManagedAgentsRedactedBlockParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "redacted") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
