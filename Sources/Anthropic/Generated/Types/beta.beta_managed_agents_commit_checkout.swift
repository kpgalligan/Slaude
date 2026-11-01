// Transformed from `anthropic.types.beta.beta_managed_agents_commit_checkout` (beta_managed_agents_commit_checkout.py).

import Foundation

public struct BetaManagedAgentsCommitCheckout: Codable, Hashable, Sendable {
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
