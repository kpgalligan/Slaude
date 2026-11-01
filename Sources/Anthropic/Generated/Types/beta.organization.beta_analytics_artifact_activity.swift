// Transformed from `anthropic.types.beta.organization.beta_analytics_artifact_activity` (beta_analytics_artifact_activity.py).

import Foundation

/// Artifact-creation activity for one (`artifact_type`, `is_shared`) bucket
/// on a given day.
///
/// Artifacts form a small finite cube — the canonical MIME type (8 values incl.
/// `other`) crossed with shared-vs-private — so the response is the full set of
/// non-empty buckets, not a ranked/paginated list. Claude Code and Cowork
/// artifacts report under `text/html` and are counted from 2026-08-17
/// onward; earlier days contain claude.ai chat artifacts only. With
/// `group_by[]=product` / `user_id` / `rbac_group_id` each row is further
/// split by the flat group keys and counts are scoped to that cut.
public struct BetaAnalyticsArtifactActivity: Codable, Hashable, Sendable {
    /// Canonical artifact MIME type (e.g.
    ///
    /// `text/markdown`, `application/vnd.ant.react`, `image/svg+xml`), or `other`.
    /// Claude Code and Cowork artifacts report as `text/html`.
    public var artifactType: String
    /// Number of artifacts created in this bucket on the requested day
    public var artifactsCreatedCount: Int
    /// Number of distinct users who created artifacts in this bucket on the requested
    /// day
    public var distinctUserCount: Int
    /// Whether the artifacts in this bucket have ever been shared (a Claude Code /
    /// Cowork artifact is shared once anyone beyond its creator may open it: named
    /// members, the whole organization, or anyone with the link).
    public var isShared: Bool
    /// Number of those artifacts that have been published (for Claude Code / Cowork
    /// artifacts: open to anyone with the link); never exceeds
    /// `artifacts_created_count`
    public var publishedArtifactsCreatedCount: Int
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

    public init(artifactType: String, artifactsCreatedCount: Int, distinctUserCount: Int, isShared: Bool, publishedArtifactsCreatedCount: Int, product: String? = nil, rbacGroupId: String? = nil, rbacGroupName: String? = nil, userId: String? = nil) {
        self.artifactType = artifactType
        self.artifactsCreatedCount = artifactsCreatedCount
        self.distinctUserCount = distinctUserCount
        self.isShared = isShared
        self.publishedArtifactsCreatedCount = publishedArtifactsCreatedCount
        self.product = product
        self.rbacGroupId = rbacGroupId
        self.rbacGroupName = rbacGroupName
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case artifactType = "artifact_type"
        case artifactsCreatedCount = "artifacts_created_count"
        case distinctUserCount = "distinct_user_count"
        case isShared = "is_shared"
        case publishedArtifactsCreatedCount = "published_artifacts_created_count"
        case product
        case rbacGroupId = "rbac_group_id"
        case rbacGroupName = "rbac_group_name"
        case userId = "user_id"
    }
}
