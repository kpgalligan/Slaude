// Transformed from `anthropic.types.beta.organization.beta_claude_tag_slack_workspace_identifiers` (beta_claude_tag_slack_workspace_identifiers.py).

import Foundation

/// The identifier Slack shows for a workspace.
///
/// It is Slack's own, not an identifier of this API.
public struct BetaClaudeTagSlackWorkspaceIdentifiers: Codable, Hashable, Sendable {
    /// Slack's identifier for the workspace, starting with `T`, such as `T0123ABCD`.
    public var workspaceID: String

    public init(workspaceID: String) {
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
    }
}
