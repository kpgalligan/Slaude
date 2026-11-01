// Transformed from `anthropic.types.beta.beta_managed_agents_budget_limit_param` (beta_managed_agents_budget_limit_param.py).

import Foundation

/// A hard spend ceiling.
///
/// The session stops issuing new model requests once the tracked list cost reaches `max_list_cost`.
public struct BetaManagedAgentsBudgetLimitParam: Codable, Hashable, Sendable {
    /// Maximum list cost the session may accrue.
    ///
    /// List price is used regardless of any negotiated discount, so the cap fires at or
    /// before the actual charge.
    public var maxListCost: BetaMonetaryAmountParam
    public var type: String

    public init(maxListCost: BetaMonetaryAmountParam, type: String = "limit") {
        self.maxListCost = maxListCost
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case maxListCost = "max_list_cost"
        case type
    }
}
