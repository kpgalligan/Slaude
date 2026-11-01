// Transformed from `anthropic.types.beta.organization.beta_analytics_project_activity` (beta_analytics_project_activity.py).

import Foundation

/// Per-project activity data for a given day.
public struct BetaAnalyticsProjectActivity: Codable, Hashable, Sendable {
    /// Number of distinct users who used the project on the requested day, or, in
    /// date-range mode, over the requested window — recomputed as an exact distinct
    /// count over the window's per-member daily rows, never a sum of per-day values.
    public var distinctUserCount: Int
    /// Number of messages sent in the project on the requested day
    public var messageCount: Int
    /// Tagged project identifier (e.g. `claude_proj_...`)
    public var projectId: String
    /// Name of the project
    public var projectName: String
    /// Project creation timestamp in RFC 3339 format.
    ///
    /// Null if the project was deleted before attribution was recorded.
    public var createdAt: Date?
    /// User who created the project.
    ///
    /// Null if the project was deleted before attribution was recorded, or if the
    /// creator's account no longer exists.
    public var createdBy: BetaAnalyticsUser?
    /// Number of distinct conversations in the project.
    ///
    /// Null on aggregated rows where a distinct count cannot be computed.
    public var distinctConversationCount: Int?
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
    public var rbacGroupId: String?
    /// Resolved RBAC group display name, alongside `rbac_group_id` when name resolution
    /// is available. Null if the group has been deleted or its name could not be
    /// resolved; `rbac_group_id` remains the stable key.
    public var rbacGroupName: String?
    /// Tagged user identifier (e.g.
    ///
    /// `user_...`). Present only when the request grouped by `user_id`.
    public var userId: String?

    public init(distinctUserCount: Int, messageCount: Int, projectId: String, projectName: String, createdAt: Date? = nil, createdBy: BetaAnalyticsUser? = nil, distinctConversationCount: Int? = nil, product: String? = nil, rbacGroupId: String? = nil, rbacGroupName: String? = nil, userId: String? = nil) {
        self.distinctUserCount = distinctUserCount
        self.messageCount = messageCount
        self.projectId = projectId
        self.projectName = projectName
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.distinctConversationCount = distinctConversationCount
        self.product = product
        self.rbacGroupId = rbacGroupId
        self.rbacGroupName = rbacGroupName
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case distinctUserCount = "distinct_user_count"
        case messageCount = "message_count"
        case projectId = "project_id"
        case projectName = "project_name"
        case createdAt = "created_at"
        case createdBy = "created_by"
        case distinctConversationCount = "distinct_conversation_count"
        case product
        case rbacGroupId = "rbac_group_id"
        case rbacGroupName = "rbac_group_name"
        case userId = "user_id"
    }
}
