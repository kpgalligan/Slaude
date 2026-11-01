// Transformed from `anthropic.types.beta.organization.beta_analytics_plugin_activity` (beta_analytics_plugin_activity.py).

import Foundation

/// Per-plugin install + invocation activity for a given day.
///
/// With `group_by[]=user_id` / `rbac_group_id` / `product` (`cowork`,
/// `claude_code` and `chat_cowork_unified` only on this endpoint) each row is
/// one (plugin, user), (plugin, group), or (plugin, product) cut: the flat
/// `user_id` / `rbac_group_id` / `product` keys carry the cut and the counts
/// are scoped to it.
public struct BetaAnalyticsPluginActivity: Codable, Hashable, Sendable {
    /// Claude Code activity metrics for a single plugin on a given day.
    public var claudeCodeMetrics: BetaAnalyticsPluginClaudeCodeMetrics
    /// Cowork activity metrics for a single plugin on a given day.
    public var coworkMetrics: BetaAnalyticsPluginCoworkMetrics
    /// Number of distinct users with recorded install or invocation activity for the
    /// plugin on the requested day (install-only users count), or, in date-range mode,
    /// over the requested window — recomputed as an exact distinct count over the
    /// window's per-member daily rows, never a sum of per-day values.
    public var distinctUserCount: Int
    /// Number of distinct users who installed the plugin on the requested day, or, in
    /// date-range mode, over the requested window — recomputed as an exact distinct
    /// count over the window's per-member daily rows, never a sum of per-day values.
    public var installCount: Int?
    /// Number of plugin invocations on the requested day
    public var invocationCount: Int
    /// Name of the plugin
    public var pluginName: String
    /// Plugin use recorded while members had Chat and Cowork unified (Cowork's features
    /// inside claude.ai chat) turned on. A count is null in date-range mode where it
    /// cannot be computed. Omitted from the response on deployments that do not offer
    /// Chat and Cowork unified.
    public var chatCoworkUnifiedMetrics: BetaAnalyticsPluginActivity.ChatCoworkUnifiedMetrics?
    /// Stable plugin identifier when available (e.g.
    ///
    /// `serena@claude-plugins-official`). Null for third-party Claude Code plugins
    /// (redacted at the source) and Cowork slash commands that carry only a hashed id.
    public var pluginID: String?
    /// Product that produced this row's activity: one of `chat`, `claude_code`,
    /// `cowork`, `office_agent`, or `chat_cowork_unified` (Chat and Cowork unified).
    /// These are the canonical Cost & Usage product names; an `office_agent` row's
    /// per-surface breakdown is in its `office_metrics`. On `/plugins` only `cowork`,
    /// `claude_code` and `chat_cowork_unified` occur (the only surfaces with plugin
    /// attribution); on `/artifacts` only `chat`, `claude_code`, `cowork` and
    /// `chat_cowork_unified` occur (the surfaces that create artifacts);
    /// `/apps/chat/projects` does not support the product dimension (a `product` entry
    /// in `group_by[]` or `filter[]` there is rejected). Present only when the request
    /// grouped by `product`.
    public var product: String?
    /// Tagged RBAC group identifier (`rbac_group_...`), matching the spend-limits API
    /// spelling. Present only when the request grouped by `rbac_group_id`.
    public var rbacGroupID: String?
    /// Resolved RBAC group display name, alongside `rbac_group_id` when name resolution
    /// is available. Null if the group has been deleted or its name could not be
    /// resolved; `rbac_group_id` remains the stable key.
    public var rbacGroupName: String?
    /// Tagged user identifier (e.g.
    ///
    /// `user_...`). Present only when the request grouped by `user_id`.
    public var userID: String?

    public init(claudeCodeMetrics: BetaAnalyticsPluginClaudeCodeMetrics, coworkMetrics: BetaAnalyticsPluginCoworkMetrics, distinctUserCount: Int, installCount: Int? = nil, invocationCount: Int, pluginName: String, chatCoworkUnifiedMetrics: BetaAnalyticsPluginActivity.ChatCoworkUnifiedMetrics? = nil, pluginID: String? = nil, product: String? = nil, rbacGroupID: String? = nil, rbacGroupName: String? = nil, userID: String? = nil) {
        self.claudeCodeMetrics = claudeCodeMetrics
        self.coworkMetrics = coworkMetrics
        self.distinctUserCount = distinctUserCount
        self.installCount = installCount
        self.invocationCount = invocationCount
        self.pluginName = pluginName
        self.chatCoworkUnifiedMetrics = chatCoworkUnifiedMetrics
        self.pluginID = pluginID
        self.product = product
        self.rbacGroupID = rbacGroupID
        self.rbacGroupName = rbacGroupName
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case claudeCodeMetrics = "claude_code_metrics"
        case coworkMetrics = "cowork_metrics"
        case distinctUserCount = "distinct_user_count"
        case installCount = "install_count"
        case invocationCount = "invocation_count"
        case pluginName = "plugin_name"
        case chatCoworkUnifiedMetrics = "chat_cowork_unified_metrics"
        case pluginID = "plugin_id"
        case product
        case rbacGroupID = "rbac_group_id"
        case rbacGroupName = "rbac_group_name"
        case userID = "user_id"
    }
}

extension BetaAnalyticsPluginActivity {

    /// Plugin use recorded while members had Chat and Cowork unified (Cowork's features inside claude.ai chat) turned on. A count is null in date-range mode where it cannot be computed. Omitted from the response on deployments that do not offer Chat and Cowork unified.
    public struct ChatCoworkUnifiedMetrics: Codable, Hashable, Sendable {
        /// Same measure as `cowork_metrics.distinct_session_plugin_used_count`, for
        /// activity recorded while members had Chat and Cowork unified turned on. Null on
        /// aggregated rows where a distinct count cannot be computed.
        public var distinctSessionPluginUsedCount: Int?

        public init(distinctSessionPluginUsedCount: Int? = nil) {
            self.distinctSessionPluginUsedCount = distinctSessionPluginUsedCount
        }

        enum CodingKeys: String, CodingKey {
            case distinctSessionPluginUsedCount = "distinct_session_plugin_used_count"
        }
    }
}
