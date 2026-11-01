// Transformed from `anthropic.types.beta.organization.beta_analytics_office_product_metrics` (beta_analytics_office_product_metrics.py).

import Foundation

/// Office Agent activity metrics for a single user on a given day within one Office product.
public struct BetaAnalyticsOfficeProductMetrics: Codable, Hashable, Sendable {
    /// Number of MCP connector invocations
    public var connectorsUsedCount: Int
    /// Number of distinct MCP connectors used.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctConnectorsUsedCount: Int?
    /// Number of distinct Office Agent sessions.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctSessionCount: Int?
    /// Number of distinct skills used.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctSkillsUsedCount: Int?
    /// Number of messages sent
    public var messageCount: Int
    /// Number of skill invocations
    public var skillsUsedCount: Int

    public init(connectorsUsedCount: Int, distinctConnectorsUsedCount: Int? = nil, distinctSessionCount: Int? = nil, distinctSkillsUsedCount: Int? = nil, messageCount: Int, skillsUsedCount: Int) {
        self.connectorsUsedCount = connectorsUsedCount
        self.distinctConnectorsUsedCount = distinctConnectorsUsedCount
        self.distinctSessionCount = distinctSessionCount
        self.distinctSkillsUsedCount = distinctSkillsUsedCount
        self.messageCount = messageCount
        self.skillsUsedCount = skillsUsedCount
    }

    enum CodingKeys: String, CodingKey {
        case connectorsUsedCount = "connectors_used_count"
        case distinctConnectorsUsedCount = "distinct_connectors_used_count"
        case distinctSessionCount = "distinct_session_count"
        case distinctSkillsUsedCount = "distinct_skills_used_count"
        case messageCount = "message_count"
        case skillsUsedCount = "skills_used_count"
    }
}
