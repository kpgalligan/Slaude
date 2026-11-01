// Transformed from `anthropic.types.beta.organization.beta_analytics_connector_activity` (beta_analytics_connector_activity.py).

import Foundation

/// Per-connector activity data for a given day.
public struct BetaAnalyticsConnectorActivity: Codable, Hashable, Sendable {
    /// Claude.ai activity metrics for a single connector on a given day.
    public var chatMetrics: BetaAnalyticsConnectorChatMetrics
    /// Claude Code activity metrics for a single connector on a given day.
    public var claudeCodeMetrics: BetaAnalyticsConnectorClaudeCodeMetrics
    /// Name of the connector.
    ///
    /// Some rows carry an opaque connector id here instead of a readable name;
    /// `connector_display_name` holds the resolved name for those rows.
    public var connectorName: String
    /// Cowork activity metrics for a single connector on a given day.
    public var coworkMetrics: BetaAnalyticsConnectorCoworkMetrics
    /// Number of distinct users who used the connector on the requested day, or, in
    /// date-range mode, over the requested window — recomputed as an exact distinct
    /// count over the window's per-member daily rows, never a sum of per-day values.
    public var distinctUserCount: Int
    /// Office Agent activity metrics for a single connector on a given day, broken out
    /// by Office product.
    public var officeMetrics: BetaAnalyticsConnectorOfficeMetrics
    /// Connector use recorded while members had Chat and Cowork unified (Cowork's
    /// features inside claude.ai chat) turned on, split into chat conversations and
    /// Cowork sessions. A count is null in date-range mode where it cannot be computed.
    /// Omitted from the response on deployments that do not offer Chat and Cowork
    /// unified.
    public var chatCoworkUnifiedMetrics: BetaAnalyticsConnectorActivity.ChatCoworkUnifiedMetrics?
    /// Human-readable display name for rows whose `connector_name` is an opaque
    /// connector id rather than a readable name, resolved at request time from the
    /// organization's connectors (including connectors that have since been removed).
    /// `connector_name` remains the row's stable key for sorting and pagination, and
    /// `filter[]=connector_name:{value}` also matches these rows by display name.
    /// Display names are not unique, and the same connector's claude.ai usage can
    /// appear under a separate row with a readable `connector_name`. Null when
    /// `connector_name` is already a readable name, when the id cannot be resolved to
    /// one of the organization's connectors, or when display-name resolution is not
    /// enabled for this organization.
    public var connectorDisplayName: String?
    /// Number of distinct users whose use of this connector on the requested day ran on
    /// their own individual credential, connected through their own consent flow.
    /// Companion bucket to `managed_auth_distinct_user_count`, which carries the
    /// measurement, attribution, and null rules. Users whose requests used no stored
    /// credential count in neither bucket.
    public var individualAuthDistinctUserCount: Int?
    /// Number of distinct users whose use of this connector on the requested day ran on
    /// Enterprise Managed Auth (an organization-managed credential provisioned through
    /// the organization's identity provider), read from the token record each request
    /// used. Null, never 0, when managed-auth reporting is not enabled for the
    /// organization, the value cannot be attributed to the row, no credentialed
    /// requests and no managed-token mint events (a managed credential being
    /// provisioned for a user's use of the connector) were observed that day, or the
    /// day predates 2026-07-01, the first day the backing data exists (forward-only
    /// data, no backfill). When credentialed requests or mint events were observed and
    /// attributed, both managed-auth fields populate, reporting 0 for a bucket with no
    /// users; the two counts are independent, not a partition — a user whose requests
    /// that day used both kinds of credential counts in both. Mint events carry user
    /// but not surface attribution, so they count as observed auth activity on
    /// `user_id` and `rbac_group_id` cuts — attributed to the user the credential was
    /// provisioned for — but never on a cut that references `product` (group or
    /// filter). Date-range rollup mode (`starting_date`/`ending_date`) computes both
    /// fields exactly over the window — distinct users with at least one qualifying day
    /// — when the whole window starts on or after 2026-07-01, with the null-versus-0
    /// and mint-event rules applying with the window in place of the day; a range
    /// starting earlier reports every managed-auth field as null, never a
    /// partial-window value.
    public var managedAuthDistinctUserCount: Int?
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
    /// Number of connector tool calls on the requested day whose trusted read-only
    /// annotation marked them read-only. Call count, not distinct users. Every call
    /// recorded on a classified surface lands in exactly one of `read_call_count`,
    /// `write_call_count`, or `unclassified_call_count`, so the three sum to the day's
    /// classified calls. Classification is forward-only per surface: claude.ai from
    /// 2026-06-01, Claude Code from 2026-05-30, Claude in Office from 2026-05-29,
    /// Cowork from 2026-06-02 (Cowork clients predating annotation forwarding land in
    /// `unclassified_call_count`). Null, never 0, when the value cannot be stated: the
    /// read/write split is not enabled for this organization, or the day predates
    /// 2026-05-29. For a date-range total, sum the per-day values, but treat a window
    /// that extends before 2026-05-29 as null rather than summing only its covered days
    /// — date-range rollup mode (`starting_date`/`ending_date`) applies both rules
    /// server-side.
    public var readCallCount: Int?
    /// Number of connector tool calls on the requested day with no trusted read-only
    /// annotation — the annotation is optional in the MCP spec and is discarded when
    /// connector access controls are active, so unclassified calls are common. This
    /// field shows how much of the day's classified activity the read/write split
    /// actually covers. Call count, not distinct users. One of the three
    /// call-classification buckets; see `read_call_count` for the per-surface
    /// data-start dates, null conditions, and date-range guidance.
    public var unclassifiedCallCount: Int?
    /// Tagged user identifier (e.g.
    ///
    /// `user_...`). Present only when the request grouped by `user_id`.
    public var userID: String?
    /// Number of connector tool calls on the requested day whose trusted read-only
    /// annotation marked them not read-only. Call count, not distinct users. One of the
    /// three call-classification buckets; see `read_call_count` for the per-surface
    /// data-start dates, null conditions, and date-range guidance.
    public var writeCallCount: Int?

    public init(chatMetrics: BetaAnalyticsConnectorChatMetrics, claudeCodeMetrics: BetaAnalyticsConnectorClaudeCodeMetrics, connectorName: String, coworkMetrics: BetaAnalyticsConnectorCoworkMetrics, distinctUserCount: Int, officeMetrics: BetaAnalyticsConnectorOfficeMetrics, chatCoworkUnifiedMetrics: BetaAnalyticsConnectorActivity.ChatCoworkUnifiedMetrics? = nil, connectorDisplayName: String? = nil, individualAuthDistinctUserCount: Int? = nil, managedAuthDistinctUserCount: Int? = nil, product: String? = nil, rbacGroupID: String? = nil, rbacGroupName: String? = nil, readCallCount: Int? = nil, unclassifiedCallCount: Int? = nil, userID: String? = nil, writeCallCount: Int? = nil) {
        self.chatMetrics = chatMetrics
        self.claudeCodeMetrics = claudeCodeMetrics
        self.connectorName = connectorName
        self.coworkMetrics = coworkMetrics
        self.distinctUserCount = distinctUserCount
        self.officeMetrics = officeMetrics
        self.chatCoworkUnifiedMetrics = chatCoworkUnifiedMetrics
        self.connectorDisplayName = connectorDisplayName
        self.individualAuthDistinctUserCount = individualAuthDistinctUserCount
        self.managedAuthDistinctUserCount = managedAuthDistinctUserCount
        self.product = product
        self.rbacGroupID = rbacGroupID
        self.rbacGroupName = rbacGroupName
        self.readCallCount = readCallCount
        self.unclassifiedCallCount = unclassifiedCallCount
        self.userID = userID
        self.writeCallCount = writeCallCount
    }

    enum CodingKeys: String, CodingKey {
        case chatMetrics = "chat_metrics"
        case claudeCodeMetrics = "claude_code_metrics"
        case connectorName = "connector_name"
        case coworkMetrics = "cowork_metrics"
        case distinctUserCount = "distinct_user_count"
        case officeMetrics = "office_metrics"
        case chatCoworkUnifiedMetrics = "chat_cowork_unified_metrics"
        case connectorDisplayName = "connector_display_name"
        case individualAuthDistinctUserCount = "individual_auth_distinct_user_count"
        case managedAuthDistinctUserCount = "managed_auth_distinct_user_count"
        case product
        case rbacGroupID = "rbac_group_id"
        case rbacGroupName = "rbac_group_name"
        case readCallCount = "read_call_count"
        case unclassifiedCallCount = "unclassified_call_count"
        case userID = "user_id"
        case writeCallCount = "write_call_count"
    }
}

extension BetaAnalyticsConnectorActivity {

    /// Connector use recorded while members had Chat and Cowork unified (Cowork's features inside claude.ai chat) turned on, split into chat conversations and Cowork sessions. A count is null in date-range mode where it cannot be computed. Omitted from the response on deployments that do not offer Chat and Cowork unified.
    public struct ChatCoworkUnifiedMetrics: Codable, Hashable, Sendable {
        /// A connector's use in chat conversations recorded while members had Chat and
        /// Cowork unified turned on.
        public var chat: BetaAnalyticsConnectorChatCoworkUnifiedChatMetrics
        /// A connector's use in Cowork sessions recorded while members had Chat and Cowork
        /// unified turned on.
        public var sessions: BetaAnalyticsConnectorChatCoworkUnifiedSessionsMetrics

        public init(chat: BetaAnalyticsConnectorChatCoworkUnifiedChatMetrics, sessions: BetaAnalyticsConnectorChatCoworkUnifiedSessionsMetrics) {
            self.chat = chat
            self.sessions = sessions
        }

        enum CodingKeys: String, CodingKey {
            case chat
            case sessions
        }
    }
}
