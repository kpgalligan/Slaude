// Transformed from `anthropic.types.beta.organization.claude_tag.bundles.beta_claude_tag_slack_channel_bundle_target_create_param` (beta_claude_tag_slack_channel_bundle_target_create_param.py).

import Foundation

/// Attach the Bundle to a Slack channel.
public struct BetaClaudeTagSlackChannelBundleTargetCreateParam: Codable, Hashable, Sendable {
    /// The identifier of the Slack channel to attach the Bundle to, starting with
    /// `slch_`. It is the channel object's `id`, not Slack's `channel_id`.
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
