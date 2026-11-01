// Transformed from `anthropic.types.beta.organization.analytics.beta_analytics_cost_metrics` (beta_analytics_cost_metrics.py).

import Foundation

/// The cost of one row.
public struct BetaAnalyticsCostMetrics: Codable, Hashable, Sendable {
    /// Amount (post-discount, pre-credit) in fractional cents (minor units).
    public var amount: String
    /// Currency code for the cost amount. Currently always `"USD"`.
    public var currency: String
    /// List-price amount (pre-discount) in fractional cents.
    public var listAmount: String
    /// Number of API requests in this row's scope.
    ///
    /// Null when `group_by` includes `cost_type` or `token_type` (the count has no
    /// per-component attribution; read it from the ungrouped response). For sandbox /
    /// code-execution events, this counts execution spans rather than HTTP requests
    /// (these rows surface with `product: null`).
    public var requests: Int?

    public init(amount: String, currency: String, listAmount: String, requests: Int? = nil) {
        self.amount = amount
        self.currency = currency
        self.listAmount = listAmount
        self.requests = requests
    }

    enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case listAmount = "list_amount"
        case requests
    }
}
