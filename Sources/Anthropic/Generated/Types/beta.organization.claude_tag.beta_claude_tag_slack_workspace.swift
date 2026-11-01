// Transformed from `anthropic.types.beta.organization.claude_tag.beta_claude_tag_slack_workspace` (beta_claude_tag_slack_workspace.py).

import Foundation

/// A Slack workspace the organization has connected, itself or through its Slack Enterprise Grid, with the settings it stores or, with `include_inherited`, the settings that apply in it.
public struct BetaClaudeTagSlackWorkspace: Codable, Hashable, Sendable {
    /// The workspace's identifier.
    ///
    /// Starts with `slws_`. It does not change for as long as the workspace is set up.
    /// A workspace that is removed and set up again has a new one, and the old one
    /// keeps returning 404; look the workspace up by its Slack identifier for the new
    /// one.
    public var id: String
    /// Time the workspace was set up, by whichever route.
    ///
    /// It does not change for as long as `id` does not.
    public var createdAt: Date
    /// What the workspace itself stores or, with `include_inherited`, what applies in
    /// it. `sources` says which.
    public var settings: BetaClaudeTagSettings
    /// Slack's own identifier for the workspace.
    public var slack: BetaClaudeTagSlackWorkspaceIdentifiers
    /// For each setting, the settings level its value in `settings` comes from.
    public var sources: BetaClaudeTagSettingSources
    public var type: String
    /// Time Claude Tag's record of the workspace last changed.
    ///
    /// It moves on every change to a setting, and can also move when something no
    /// response holds changes, so a later value says to read the workspace again, not
    /// that a setting changed. Attaching or detaching a Bundle does not by itself move
    /// it.
    public var updatedAt: Date

    public init(id: String, createdAt: Date, settings: BetaClaudeTagSettings, slack: BetaClaudeTagSlackWorkspaceIdentifiers, sources: BetaClaudeTagSettingSources, type: String = "slack_workspace", updatedAt: Date) {
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
