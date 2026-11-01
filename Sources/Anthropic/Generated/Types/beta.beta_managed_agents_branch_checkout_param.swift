// Transformed from `anthropic.types.beta.beta_managed_agents_branch_checkout_param` (beta_managed_agents_branch_checkout_param.py).

import Foundation

public struct BetaManagedAgentsBranchCheckoutParam: Codable, Hashable, Sendable {
    /// Branch name to check out.
    public var name: String
    public var type: String

    public init(name: String, type: String = "branch") {
        self.name = name
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
    }
}
