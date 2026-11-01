// Transformed from `anthropic.types.beta.organization.claude_tag.bundles.beta_claude_tag_slack_channel_bundle_target` (beta_claude_tag_slack_channel_bundle_target.py).

import Foundation

/// One Bundle attached to one Slack channel.
///
/// The Bundle can be used in that channel only.
public struct BetaClaudeTagSlackChannelBundleTarget: Codable, Hashable, Sendable {
    /// The Bundle Target's identifier.
    ///
    /// Starts with `btgt_`. No two Bundle Targets have the same one, and the same
    /// Bundle and target always give the same one, also after a detach and a new
    /// attach. It is opaque.
    public var id: String
    /// Time the Bundle was attached.
    public var createdAt: Date
    /// The identifier of the Slack channel the Bundle is attached to, starting with
    /// `slch_`. It is the channel object's `id`, not Slack's `channel_id`.
    public var slackChannelId: String
    public var type: String

    public init(id: String, createdAt: Date, slackChannelId: String, type: String = "slack_channel") {
        self.id = id
        self.createdAt = createdAt
        self.slackChannelId = slackChannelId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case slackChannelId = "slack_channel_id"
        case type
    }
}
