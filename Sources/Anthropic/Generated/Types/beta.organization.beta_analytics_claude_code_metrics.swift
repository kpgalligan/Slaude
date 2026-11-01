// Transformed from `anthropic.types.beta.organization.beta_analytics_claude_code_metrics` (beta_analytics_claude_code_metrics.py).

import Foundation

/// Claude Code activity metrics for a single user on a given day.
public struct BetaAnalyticsClaudeCodeMetrics: Codable, Hashable, Sendable {
    /// Core Claude Code activity metrics for a single user on a given day.
    public var coreMetrics: BetaAnalyticsCoreCodeMetrics
    /// Per-tool accepted/rejected counts for Claude Code file modification tools.
    public var toolActions: BetaAnalyticsToolActions

    public init(coreMetrics: BetaAnalyticsCoreCodeMetrics, toolActions: BetaAnalyticsToolActions) {
        self.coreMetrics = coreMetrics
        self.toolActions = toolActions
    }

    enum CodingKeys: String, CodingKey {
        case coreMetrics = "core_metrics"
        case toolActions = "tool_actions"
    }
}
