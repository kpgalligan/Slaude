// Transformed from `anthropic.types.beta.organization.beta_claude_tag_slack_channel_identifiers_param` (beta_claude_tag_slack_channel_identifiers_param.py).

import Foundation

/// The identifiers Slack shows for a channel.
///
/// They are Slack's own, not identifiers of this API.
public struct BetaClaudeTagSlackChannelIdentifiersParam: Codable, Hashable, Sendable {
    /// Slack's identifier for the channel, starting with `C` or `G`, such as
    /// `C0456EFGH`.
    public var channelId: String
    /// Slack's identifier for the workspace the channel is in, starting with `T`, such
    /// as `T0123ABCD`.
    public var workspaceId: String

    public init(channelId: String, workspaceId: String) {
        self.channelId = channelId
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case channelId = "channel_id"
        case workspaceId = "workspace_id"
    }
}
