// Transformed from `anthropic.types.beta.organization.claude_tag.slack_channel_list_params` (slack_channel_list_params.py).

import Foundation

public struct SlackChannelListParams: Codable, Hashable, Sendable {
    /// The Slack workspace whose channels to list: Slack's identifier for it, as in the
    /// channel object's `slack.workspace_id`, not the workspace object's `id`.
    public var slackWorkspaceID: String
    /// When `true`, `settings` holds what applies in each channel once the settings
    /// levels above it are taken into account, and every member of `sources` names the
    /// level a value comes from. When `false` or left out, `settings` holds what each
    /// channel itself stores.
    public var includeInherited: Bool?
    /// Number of items to return per page, between 1 and 100. Defaults to 20.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String?
    /// Slack's identifier for one channel of that workspace, as in the channel object's
    /// `slack.channel_id`. It is not the channel object's `id`. With it `data` holds
    /// that channel alone, or nothing when the channel is not set up.
    public var slackChannelID: String?
    /// This endpoint is in beta: requests must send
    /// `experimental-claude-tag-2026-10-21` in this header.
    public var betas: [AnthropicBetaParam]?

    public init(slackWorkspaceID: String, includeInherited: Bool? = nil, limit: Int? = nil, page: String? = nil, slackChannelID: String? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.slackWorkspaceID = slackWorkspaceID
        self.includeInherited = includeInherited
        self.limit = limit
        self.page = page
        self.slackChannelID = slackChannelID
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case slackWorkspaceID = "slack_workspace_id"
        case includeInherited = "include_inherited"
        case limit
        case page
        case slackChannelID = "slack_channel_id"
        case betas
    }
}
