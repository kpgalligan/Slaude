// Transformed from `anthropic.types.beta.organization.beta_claude_tag_slack_channel_setting_source` (beta_claude_tag_slack_channel_setting_source.py).

import Foundation

/// The value comes from the addressed Slack channel itself.
public struct BetaClaudeTagSlackChannelSettingSource: Codable, Hashable, Sendable {
    /// The channel's identifier, starting with `slch_`.
    public var slackChannelId: String
    public var type: String

    public init(slackChannelId: String, type: String = "slack_channel") {
        self.slackChannelId = slackChannelId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case slackChannelId = "slack_channel_id"
        case type
    }
}
