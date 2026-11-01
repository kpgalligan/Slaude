// Transformed from `anthropic.types.beta.beta_managed_agents_commit_checkout_param` (beta_managed_agents_commit_checkout_param.py).

import Foundation

public struct BetaManagedAgentsCommitCheckoutParam: Codable, Hashable, Sendable {
    /// Full commit SHA to check out.
    public var sha: String
    public var type: String

    public init(sha: String, type: String = "commit") {
        self.sha = sha
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case sha
        case type
    }
}
