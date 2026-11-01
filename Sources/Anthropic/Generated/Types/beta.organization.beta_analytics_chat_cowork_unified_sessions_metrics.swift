// Transformed from `anthropic.types.beta.organization.beta_analytics_chat_cowork_unified_sessions_metrics` (beta_analytics_chat_cowork_unified_sessions_metrics.py).

import Foundation

/// Cowork session activity recorded while members had Chat and Cowork
/// unified turned on.
public struct BetaAnalyticsChatCoworkUnifiedSessionsMetrics: Codable, Hashable, Sendable {
    /// Same measure as `cowork_metrics.action_count`, for activity recorded while
    /// members had Chat and Cowork unified turned on.
    public var actionCount: Int
    /// Same measure as `cowork_metrics.artifacts_created_count`, for activity recorded
    /// while members had Chat and Cowork unified turned on. Exact in date-range mode: a
    /// creation belongs to exactly one day, so the per-day counts never overlap and
    /// their sum over the window is the exact count of distinct creations in it.
    public var artifactsCreatedCount: Int
    /// Same measure as `cowork_metrics.connectors_used_count`, for activity recorded
    /// while members had Chat and Cowork unified turned on.
    public var connectorsUsedCount: Int
    /// Same measure as `cowork_metrics.dispatch_turn_count`, for activity recorded
    /// while members had Chat and Cowork unified turned on.
    public var dispatchTurnCount: Int
    /// Same measure as `cowork_metrics.distinct_connectors_used_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. Approximate (HLL,
    /// typical error <2%) in date-range mode. Null on aggregated rows where a distinct
    /// count cannot be computed.
    public var distinctConnectorsUsedCount: Int?
    /// Same measure as `cowork_metrics.distinct_plugins_used_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. Approximate (HLL,
    /// typical error <2%) in date-range mode. Null on aggregated rows where a distinct
    /// count cannot be computed.
    public var distinctPluginsUsedCount: Int?
    /// Same measure as `cowork_metrics.distinct_session_count`, for activity recorded
    /// while members had Chat and Cowork unified turned on. Approximate (HLL, typical
    /// error <2%) in date-range mode. Null on aggregated rows where a distinct count
    /// cannot be computed.
    public var distinctSessionCount: Int?
    /// Same measure as `cowork_metrics.distinct_skills_used_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. Approximate (HLL,
    /// typical error <2%) in date-range mode. Null on aggregated rows where a distinct
    /// count cannot be computed.
    public var distinctSkillsUsedCount: Int?
    /// Same measure as `cowork_metrics.edit_tool_count`, for activity recorded while
    /// members had Chat and Cowork unified turned on.
    public var editToolCount: Int?
    /// Same measure as `cowork_metrics.file_edit_count`, for activity recorded while
    /// members had Chat and Cowork unified turned on.
    public var fileEditCount: Int?
    /// Same measure as `cowork_metrics.message_count`, for activity recorded while
    /// members had Chat and Cowork unified turned on.
    public var messageCount: Int
    /// Same measure as `cowork_metrics.multi_edit_tool_count`, for activity recorded
    /// while members had Chat and Cowork unified turned on. Claude no longer has a
    /// multi-edit tool, so expect 0 when not null; each edit is now a separate Edit
    /// tool call, counted in `edit_tool_count` and `file_edit_count`.
    public var multiEditToolCount: Int?
    /// Same measure as `cowork_metrics.notebook_edit_tool_count`, for activity recorded
    /// while members had Chat and Cowork unified turned on.
    public var notebookEditToolCount: Int?
    /// Same measure as `cowork_metrics.plugins_used_count`, for activity recorded while
    /// members had Chat and Cowork unified turned on.
    public var pluginsUsedCount: Int?
    /// Same measure as `cowork_metrics.sessions_with_file_edits_count`, for activity
    /// recorded while members had Chat and Cowork unified turned on. Approximate (HLL,
    /// typical error <2%) in date-range mode. Null on aggregated rows where a distinct
    /// count cannot be computed.
    public var sessionsWithFileEditsCount: Int?
    /// Same measure as `cowork_metrics.skills_used_count`, for activity recorded while
    /// members had Chat and Cowork unified turned on.
    public var skillsUsedCount: Int
    /// Same measure as `cowork_metrics.write_tool_count`, for activity recorded while
    /// members had Chat and Cowork unified turned on.
    public var writeToolCount: Int?

    public init(actionCount: Int, artifactsCreatedCount: Int, connectorsUsedCount: Int, dispatchTurnCount: Int, distinctConnectorsUsedCount: Int? = nil, distinctPluginsUsedCount: Int? = nil, distinctSessionCount: Int? = nil, distinctSkillsUsedCount: Int? = nil, editToolCount: Int? = nil, fileEditCount: Int? = nil, messageCount: Int, multiEditToolCount: Int? = nil, notebookEditToolCount: Int? = nil, pluginsUsedCount: Int? = nil, sessionsWithFileEditsCount: Int? = nil, skillsUsedCount: Int, writeToolCount: Int? = nil) {
        self.actionCount = actionCount
        self.artifactsCreatedCount = artifactsCreatedCount
        self.connectorsUsedCount = connectorsUsedCount
        self.dispatchTurnCount = dispatchTurnCount
        self.distinctConnectorsUsedCount = distinctConnectorsUsedCount
        self.distinctPluginsUsedCount = distinctPluginsUsedCount
        self.distinctSessionCount = distinctSessionCount
        self.distinctSkillsUsedCount = distinctSkillsUsedCount
        self.editToolCount = editToolCount
        self.fileEditCount = fileEditCount
        self.messageCount = messageCount
        self.multiEditToolCount = multiEditToolCount
        self.notebookEditToolCount = notebookEditToolCount
        self.pluginsUsedCount = pluginsUsedCount
        self.sessionsWithFileEditsCount = sessionsWithFileEditsCount
        self.skillsUsedCount = skillsUsedCount
        self.writeToolCount = writeToolCount
    }

    enum CodingKeys: String, CodingKey {
        case actionCount = "action_count"
        case artifactsCreatedCount = "artifacts_created_count"
        case connectorsUsedCount = "connectors_used_count"
        case dispatchTurnCount = "dispatch_turn_count"
        case distinctConnectorsUsedCount = "distinct_connectors_used_count"
        case distinctPluginsUsedCount = "distinct_plugins_used_count"
        case distinctSessionCount = "distinct_session_count"
        case distinctSkillsUsedCount = "distinct_skills_used_count"
        case editToolCount = "edit_tool_count"
        case fileEditCount = "file_edit_count"
        case messageCount = "message_count"
        case multiEditToolCount = "multi_edit_tool_count"
        case notebookEditToolCount = "notebook_edit_tool_count"
        case pluginsUsedCount = "plugins_used_count"
        case sessionsWithFileEditsCount = "sessions_with_file_edits_count"
        case skillsUsedCount = "skills_used_count"
        case writeToolCount = "write_tool_count"
    }
}
