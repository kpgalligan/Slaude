// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_budget_reached` (beta_managed_agents_session_budget_reached.py).

import Foundation

/// The agent stopped because the session's tracked list cost reached its budget, or because its usage includes a model with no list price (which the budget cannot measure). Raise the budget to continue — or, if raising is rejected because a model has no list price, remove the budget.
public struct BetaManagedAgentsSessionBudgetReached: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "budget_reached") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
