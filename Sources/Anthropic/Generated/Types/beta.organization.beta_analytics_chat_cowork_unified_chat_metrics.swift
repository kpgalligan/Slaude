// Transformed from `anthropic.types.beta.organization.beta_analytics_chat_cowork_unified_chat_metrics` (beta_analytics_chat_cowork_unified_chat_metrics.py).

import Foundation

/// Chat activity recorded while members had Chat and Cowork unified turned
/// on.
public struct BetaAnalyticsChatCoworkUnifiedChatMetrics: Codable, Hashable, Sendable {
    /// Same measure as `chat_metrics.connectors_used_count`, for activity recorded
    /// while members had Chat and Cowork unified turned on.
    public var connectorsUsedCount: Int
    /// Same measure as `chat_metrics.distinct_artifacts_created_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. Exact in
    /// date-range mode: a creation belongs to exactly one day, so the per-day counts
    /// never overlap and their sum over the window is the exact count of distinct
    /// creations in it.
    public var distinctArtifactsCreatedCount: Int
    /// Same measure as `chat_metrics.distinct_connectors_used_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. Approximate (HLL,
    /// typical error <2%) in date-range mode. Null on aggregated rows where a distinct
    /// count cannot be computed.
    public var distinctConnectorsUsedCount: Int?
    /// Same measure as `chat_metrics.distinct_conversation_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. Approximate (HLL,
    /// typical error <2%) in date-range mode. Null on aggregated rows where a distinct
    /// count cannot be computed.
    public var distinctConversationCount: Int?
    /// Same measure as `chat_metrics.distinct_files_uploaded_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. It counts uploaded
    /// files as well as files Claude created and images returned by Claude's tools,
    /// such as screenshots. Approximate (HLL, typical error <2%) in date-range mode.
    /// Null on aggregated rows where a distinct count cannot be computed.
    public var distinctFilesUploadedCount: Int?
    /// Same measure as `chat_metrics.distinct_projects_created_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. Exact in
    /// date-range mode: a creation belongs to exactly one day, so the per-day counts
    /// never overlap and their sum over the window is the exact count of distinct
    /// creations in it.
    public var distinctProjectsCreatedCount: Int
    /// Same measure as `chat_metrics.distinct_projects_used_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. Approximate (HLL,
    /// typical error <2%) in date-range mode. Null on aggregated rows where a distinct
    /// count cannot be computed.
    public var distinctProjectsUsedCount: Int?
    /// Always null: shared-artifact views are not currently measured.
    public var distinctSharedArtifactsViewedCount: Int?
    /// Same measure as `chat_metrics.distinct_skills_used_count`, for activity recorded
    /// while members had Chat and Cowork unified turned on. Approximate (HLL, typical
    /// error <2%) in date-range mode. Null on aggregated rows where a distinct count
    /// cannot be computed.
    public var distinctSkillsUsedCount: Int?
    /// Same measure as `chat_metrics.message_count`, for activity recorded while
    /// members had Chat and Cowork unified turned on.
    public var messageCount: Int
    /// Same measure as `chat_metrics.shared_conversations_viewed_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on.
    public var sharedConversationsViewedCount: Int
    /// Same measure as `chat_metrics.thinking_message_count`, for activity recorded
    /// while members had Chat and Cowork unified turned on.
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
