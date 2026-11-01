// Transformed from `anthropic.types.beta.organization.beta_analytics_chat_metrics` (beta_analytics_chat_metrics.py).

import Foundation

/// Claude.ai activity metrics for a single user on a given day.
public struct BetaAnalyticsChatMetrics: Codable, Hashable, Sendable {
    /// Number of MCP connector invocations.
    public var connectorsUsedCount: Int
    /// Number of distinct artifacts created.
    ///
    /// Exact in date-range mode: a creation belongs to exactly one day, so the per-day
    /// counts never overlap and their sum over the window is the exact count of
    /// distinct creations in it.
    public var distinctArtifactsCreatedCount: Int
    /// Distinct claude.ai connectors this user used.
    ///
    /// Excludes calls whose connector could not be identified and all calls from
    /// organizations with zero data retention. Approximate (HLL, typical error <2%) in
    /// date-range mode. Null on aggregated rows where a distinct count cannot be
    /// computed.
    public var distinctConnectorsUsedCount: Int?
    /// Number of distinct conversations the user participated in.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctConversationCount: Int?
    /// Number of distinct files uploaded.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctFilesUploadedCount: Int?
    /// Number of distinct projects created.
    ///
    /// Exact in date-range mode: a creation belongs to exactly one day, so the per-day
    /// counts never overlap and their sum over the window is the exact count of
    /// distinct creations in it.
    public var distinctProjectsCreatedCount: Int
    /// Number of distinct projects used.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctProjectsUsedCount: Int?
    /// Number of distinct shared artifacts the user viewed.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctSharedArtifactsViewedCount: Int?
    /// Number of distinct skills used.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctSkillsUsedCount: Int?
    /// Number of messages sent
    public var messageCount: Int
    /// Number of times the user opened a shared conversation in a project
    public var sharedConversationsViewedCount: Int
    /// Number of messages that used extended thinking
    public var thinkingMessageCount: Int

    public init(connectorsUsedCount: Int, distinctArtifactsCreatedCount: Int, distinctConnectorsUsedCount: Int? = nil, distinctConversationCount: Int? = nil, distinctFilesUploadedCount: Int? = nil, distinctProjectsCreatedCount: Int, distinctProjectsUsedCount: Int? = nil, distinctSharedArtifactsViewedCount: Int? = nil, distinctSkillsUsedCount: Int? = nil, messageCount: Int, sharedConversationsViewedCount: Int, thinkingMessageCount: Int) {
        self.connectorsUsedCount = connectorsUsedCount
        self.distinctArtifactsCreatedCount = distinctArtifactsCreatedCount
        self.distinctConnectorsUsedCount = distinctConnectorsUsedCount
        self.distinctConversationCount = distinctConversationCount
        self.distinctFilesUploadedCount = distinctFilesUploadedCount
        self.distinctProjectsCreatedCount = distinctProjectsCreatedCount
        self.distinctProjectsUsedCount = distinctProjectsUsedCount
        self.distinctSharedArtifactsViewedCount = distinctSharedArtifactsViewedCount
        self.distinctSkillsUsedCount = distinctSkillsUsedCount
        self.messageCount = messageCount
        self.sharedConversationsViewedCount = sharedConversationsViewedCount
        self.thinkingMessageCount = thinkingMessageCount
    }

    enum CodingKeys: String, CodingKey {
        case connectorsUsedCount = "connectors_used_count"
        case distinctArtifactsCreatedCount = "distinct_artifacts_created_count"
        case distinctConnectorsUsedCount = "distinct_connectors_used_count"
        case distinctConversationCount = "distinct_conversation_count"
        case distinctFilesUploadedCount = "distinct_files_uploaded_count"
        case distinctProjectsCreatedCount = "distinct_projects_created_count"
        case distinctProjectsUsedCount = "distinct_projects_used_count"
        case distinctSharedArtifactsViewedCount = "distinct_shared_artifacts_viewed_count"
        case distinctSkillsUsedCount = "distinct_skills_used_count"
        case messageCount = "message_count"
        case sharedConversationsViewedCount = "shared_conversations_viewed_count"
        case thinkingMessageCount = "thinking_message_count"
    }
}
