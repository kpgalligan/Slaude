// Transformed from `anthropic.types.beta.organization.claude_tag.beta_claude_tag_deleted_slack_channel` (beta_claude_tag_deleted_slack_channel.py).

import Foundation

/// Confirms that a Slack channel was removed from Claude Tag.
public struct BetaClaudeTagDeletedSlackChannel: Codable, Hashable, Sendable {
    /// The removed channel's identifier.
    public var id: String
    public var type: String

    public init(id: String, type: String = "slack_channel_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
