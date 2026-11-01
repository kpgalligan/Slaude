// Transformed from `anthropic.types.beta.organization.beta_claude_tag_slack_grid_channel_setting_source` (beta_claude_tag_slack_grid_channel_setting_source.py).

import Foundation

/// The value comes from the addressed channel as it is set up under another workspace of its Enterprise Grid: a channel shared across the Grid keeps one Slack channel identifier in every workspace that sees it.
public struct BetaClaudeTagSlackGridChannelSettingSource: Codable, Hashable, Sendable {
    /// Slack's own identifiers for the channel under that other workspace.
    public var slack: BetaClaudeTagSlackChannelIdentifiers
    public var type: String

    public init(slack: BetaClaudeTagSlackChannelIdentifiers, type: String = "slack_grid_channel") {
        self.slack = slack
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case slack
        case type
    }
}
