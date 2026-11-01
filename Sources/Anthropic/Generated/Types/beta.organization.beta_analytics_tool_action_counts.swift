// Transformed from `anthropic.types.beta.organization.beta_analytics_tool_action_counts` (beta_analytics_tool_action_counts.py).

import Foundation

/// Accepted/rejected counts for a single Claude Code tool type.
public struct BetaAnalyticsToolActionCounts: Codable, Hashable, Sendable {
    /// Number of tool proposals accepted
    public var acceptedCount: Int
    /// Number of tool proposals rejected
    public var rejectedCount: Int

    public init(acceptedCount: Int, rejectedCount: Int) {
        self.acceptedCount = acceptedCount
        self.rejectedCount = rejectedCount
    }

    enum CodingKeys: String, CodingKey {
        case acceptedCount = "accepted_count"
        case rejectedCount = "rejected_count"
    }
}
