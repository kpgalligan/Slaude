// Transformed from `anthropic.types.beta.organization.beta_claude_tag_slack_parent_channel_setting_source` (beta_claude_tag_slack_parent_channel_setting_source.py).

import Foundation

/// The value comes from the channel that a code channel was started from.
///
/// A parent channel contributes `instructions` and `environment_id` only.
public struct BetaClaudeTagSlackParentChannelSettingSource: Codable, Hashable, Sendable {
    /// The parent channel's identifier, starting with `slch_`.
    public var slackChannelId: String
    public var type: String

    public init(slackChannelId: String, type: String = "slack_parent_channel") {
        self.slackChannelId = slackChannelId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case slackChannelId = "slack_channel_id"
        case type
    }
}
