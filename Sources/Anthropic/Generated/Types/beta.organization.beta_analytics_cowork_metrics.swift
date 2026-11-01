// Transformed from `anthropic.types.beta.organization.beta_analytics_cowork_metrics` (beta_analytics_cowork_metrics.py).

import Foundation

/// Cowork activity metrics for a single user on a given day.
public struct BetaAnalyticsCoworkMetrics: Codable, Hashable, Sendable {
    /// Number of tool actions completed in Cowork sessions
    public var actionCount: Int
    /// Number of artifacts created in Cowork sessions: an artifact counts once, on the
    /// day a session first saves it. Counted from 2026-08-17; 0 on earlier days. Exact
    /// in date-range mode: a creation belongs to exactly one day, so the per-day counts
    /// never overlap and their sum over the window is the exact count of distinct
    /// creations in it.
    public var artifactsCreatedCount: Int
    /// Total number of connector invocations in Cowork sessions
    public var connectorsUsedCount: Int
    /// Number of Dispatch (background agent) turns completed
    public var dispatchTurnCount: Int
    /// Number of distinct connectors used in Cowork sessions.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctConnectorsUsedCount: Int?
    /// Number of distinct Cowork sessions.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctSessionCount: Int?
    /// Number of distinct skills used in Cowork sessions.
    ///
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctSkillsUsedCount: Int?
    /// Number of messages sent in Cowork sessions
    public var messageCount: Int
    /// Total number of skill invocations in Cowork sessions
    public var skillsUsedCount: Int
    /// Number of distinct plugins used in Cowork sessions.
    ///
    /// Null while Cowork plugin-use metrics are not enabled for this organization.
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var distinctPluginsUsedCount: Int?
    /// Number of successful Edit tool calls in Cowork sessions.
    ///
    /// Null while the file-edit metrics are not enabled for this organization.
    public var editToolCount: Int?
    /// Number of successful file-edit tool calls (Edit, MultiEdit, Write, NotebookEdit)
    /// in Cowork sessions. Null, never 0, while the file-edit metrics are not enabled
    /// for this organization.
    public var fileEditCount: Int?
    /// Number of successful MultiEdit tool calls in Cowork sessions.
    ///
    /// Null while the file-edit metrics are not enabled for this organization.
    public var multiEditToolCount: Int?
    /// Number of successful NotebookEdit tool calls in Cowork sessions.
    ///
    /// Null while the file-edit metrics are not enabled for this organization.
    public var notebookEditToolCount: Int?
    /// Total number of plugin invocations in Cowork sessions.
    ///
    /// Null while Cowork plugin-use metrics are not enabled for this organization.
    public var pluginsUsedCount: Int?
    /// Number of distinct Cowork sessions with at least one successful file-edit tool
    /// call. Null while the file-edit metrics are not enabled for this organization.
    /// Approximate (HLL, typical error <2%) in date-range mode. Null on aggregated rows
    /// where a distinct count cannot be computed.
    public var sessionsWithFileEditsCount: Int?
    /// Number of successful Write tool calls in Cowork sessions.
    ///
    /// Null while the file-edit metrics are not enabled for this organization.
    public var writeToolCount: Int?

    public init(actionCount: Int, artifactsCreatedCount: Int, connectorsUsedCount: Int, dispatchTurnCount: Int, distinctConnectorsUsedCount: Int? = nil, distinctSessionCount: Int? = nil, distinctSkillsUsedCount: Int? = nil, messageCount: Int, skillsUsedCount: Int, distinctPluginsUsedCount: Int? = nil, editToolCount: Int? = nil, fileEditCount: Int? = nil, multiEditToolCount: Int? = nil, notebookEditToolCount: Int? = nil, pluginsUsedCount: Int? = nil, sessionsWithFileEditsCount: Int? = nil, writeToolCount: Int? = nil) {
        self.actionCount = actionCount
        self.artifactsCreatedCount = artifactsCreatedCount
        self.connectorsUsedCount = connectorsUsedCount
        self.dispatchTurnCount = dispatchTurnCount
        self.distinctConnectorsUsedCount = distinctConnectorsUsedCount
        self.distinctSessionCount = distinctSessionCount
        self.distinctSkillsUsedCount = distinctSkillsUsedCount
        self.messageCount = messageCount
        self.skillsUsedCount = skillsUsedCount
        self.distinctPluginsUsedCount = distinctPluginsUsedCount
        self.editToolCount = editToolCount
        self.fileEditCount = fileEditCount
        self.multiEditToolCount = multiEditToolCount
        self.notebookEditToolCount = notebookEditToolCount
        self.pluginsUsedCount = pluginsUsedCount
        self.sessionsWithFileEditsCount = sessionsWithFileEditsCount
        self.writeToolCount = writeToolCount
    }

    enum CodingKeys: String, CodingKey {
        case actionCount = "action_count"
        case artifactsCreatedCount = "artifacts_created_count"
        case connectorsUsedCount = "connectors_used_count"
        case dispatchTurnCount = "dispatch_turn_count"
        case distinctConnectorsUsedCount = "distinct_connectors_used_count"
        case distinctSessionCount = "distinct_session_count"
        case distinctSkillsUsedCount = "distinct_skills_used_count"
        case messageCount = "message_count"
        case skillsUsedCount = "skills_used_count"
        case distinctPluginsUsedCount = "distinct_plugins_used_count"
        case editToolCount = "edit_tool_count"
        case fileEditCount = "file_edit_count"
        case multiEditToolCount = "multi_edit_tool_count"
        case notebookEditToolCount = "notebook_edit_tool_count"
        case pluginsUsedCount = "plugins_used_count"
        case sessionsWithFileEditsCount = "sessions_with_file_edits_count"
        case writeToolCount = "write_tool_count"
    }
}
