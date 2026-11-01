// Transformed from `anthropic.types.beta.organization.beta_analytics_tool_actions` (beta_analytics_tool_actions.py).

import Foundation

/// Per-tool accepted/rejected counts for Claude Code file modification tools.
public struct BetaAnalyticsToolActions: Codable, Hashable, Sendable {
    /// Accepted/rejected counts for a single Claude Code tool type.
    public var editTool: BetaAnalyticsToolActionCounts
    /// Accepted/rejected counts for a single Claude Code tool type.
    public var multiEditTool: BetaAnalyticsToolActionCounts
    /// Accepted/rejected counts for a single Claude Code tool type.
    public var notebookEditTool: BetaAnalyticsToolActionCounts
    /// Accepted/rejected counts for a single Claude Code tool type.
    public var writeTool: BetaAnalyticsToolActionCounts

    public init(editTool: BetaAnalyticsToolActionCounts, multiEditTool: BetaAnalyticsToolActionCounts, notebookEditTool: BetaAnalyticsToolActionCounts, writeTool: BetaAnalyticsToolActionCounts) {
        self.editTool = editTool
        self.multiEditTool = multiEditTool
        self.notebookEditTool = notebookEditTool
        self.writeTool = writeTool
    }

    enum CodingKeys: String, CodingKey {
        case editTool = "edit_tool"
        case multiEditTool = "multi_edit_tool"
        case notebookEditTool = "notebook_edit_tool"
        case writeTool = "write_tool"
    }
}
