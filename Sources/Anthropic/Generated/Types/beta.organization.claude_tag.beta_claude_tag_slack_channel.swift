// Transformed from `anthropic.types.beta.organization.claude_tag.beta_claude_tag_slack_channel` (beta_claude_tag_slack_channel.py).

import Foundation

/// A Slack channel set up for Claude Tag, with the settings it stores or, with `include_inherited`, the settings that apply in it.
public struct BetaClaudeTagSlackChannel: Codable, Hashable, Sendable {
    /// The channel's identifier.
    ///
    /// Starts with `slch_`. It does not change for as long as the channel is set up,
    /// with one exception: a channel that is not configured gets a new one when
    /// claude.ai replaces its record, which happens only while the organization's
    /// read-only mode is off. A channel that is removed and set up again also has a new
    /// one. The old one keeps returning 404; look the channel up by its Slack
    /// identifiers for the new one.
    public var id: String
    /// Time the channel was set up, by whichever route.
    ///
    /// It does not change for as long as `id` does not.
    public var createdAt: Date
    /// What the channel itself stores or, with `include_inherited`, what applies in it.
    ///
    /// `sources` says which.
    public var settings: BetaClaudeTagSettings
    /// Slack's own identifiers for the channel.
    public var slack: BetaClaudeTagSlackChannelIdentifiers
    /// For each setting, the settings level its value in `settings` comes from.
    public var sources: BetaClaudeTagSettingSources
    public var type: String
    /// Time Claude Tag's record of the channel last changed.
    ///
    /// It moves on every change to a setting, and can also move when something no
    /// response holds changes, so a later value says to read the channel again, not
    /// that a setting changed. Attaching or detaching a Bundle does not by itself move
    /// it.
    public var updatedAt: Date

    public init(id: String, createdAt: Date, settings: BetaClaudeTagSettings, slack: BetaClaudeTagSlackChannelIdentifiers, sources: BetaClaudeTagSettingSources, type: String = "slack_channel", updatedAt: Date) {
        self.id = id
        self.createdAt = createdAt
        self.settings = settings
        self.slack = slack
        self.sources = sources
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case settings
        case slack
        case sources
        case type
        case updatedAt = "updated_at"
    }
}
