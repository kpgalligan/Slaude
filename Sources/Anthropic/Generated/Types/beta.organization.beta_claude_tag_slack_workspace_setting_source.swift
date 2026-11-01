// Transformed from `anthropic.types.beta.organization.beta_claude_tag_slack_workspace_setting_source` (beta_claude_tag_slack_workspace_setting_source.py).

import Foundation

/// The value comes from a Slack workspace of the organization.
public struct BetaClaudeTagSlackWorkspaceSettingSource: Codable, Hashable, Sendable {
    /// The workspace's identifier, starting with `slws_`.
    public var slackWorkspaceId: String
    public var type: String

    public init(slackWorkspaceId: String, type: String = "slack_workspace") {
        self.slackWorkspaceId = slackWorkspaceId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case slackWorkspaceId = "slack_workspace_id"
        case type
    }
}
