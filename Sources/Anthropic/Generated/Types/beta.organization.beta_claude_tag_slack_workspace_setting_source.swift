// Transformed from `anthropic.types.beta.organization.beta_claude_tag_slack_workspace_setting_source` (beta_claude_tag_slack_workspace_setting_source.py).

import Foundation

/// The value comes from a Slack workspace of the organization.
public struct BetaClaudeTagSlackWorkspaceSettingSource: Codable, Hashable, Sendable {
    /// The workspace's identifier, starting with `slws_`.
    public var slackWorkspaceID: String
    public var type: String

    public init(slackWorkspaceID: String, type: String = "slack_workspace") {
        self.slackWorkspaceID = slackWorkspaceID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case slackWorkspaceID = "slack_workspace_id"
        case type
    }
}
