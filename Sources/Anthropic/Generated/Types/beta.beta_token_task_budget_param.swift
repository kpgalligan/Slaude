// Transformed from `anthropic.types.beta.beta_token_task_budget_param` (beta_token_task_budget_param.py).

import Foundation

/// User-configurable total token budget across contexts.
public struct BetaTokenTaskBudgetParam: Codable, Hashable, Sendable {
    /// Total token budget across all contexts in the session.
    public var total: Int
    /// The budget type. Currently only 'tokens' is supported.
    public var type: String
    /// Remaining tokens in the budget.
    ///
    /// Use this to track usage across contexts when implementing compaction
    /// client-side. Defaults to total if not provided.
    public var remaining: Int??

    public init(total: Int, type: String = "tokens", remaining: Int?? = nil) {
        self.total = total
        self.type = type
        self.remaining = remaining
    }

    enum CodingKeys: String, CodingKey {
        case total
        case type
        case remaining
    }
}
