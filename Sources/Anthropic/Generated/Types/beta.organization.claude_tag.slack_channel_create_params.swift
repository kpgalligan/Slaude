// Transformed from `anthropic.types.beta.organization.claude_tag.slack_channel_create_params` (slack_channel_create_params.py).

import Foundation

public struct SlackChannelCreateParams: Codable, Hashable, Sendable {
    /// Slack's own identifiers for the channel to set up.
    ///
    /// The organization must own the workspace.
    public var slack: BetaClaudeTagSlackChannelIdentifiersParam
    /// Settings to store on the channel, applied as Update Slack Channel applies them.
    public var settings: BetaClaudeTagSettingsCreateParam?
    /// This endpoint is in beta: requests must send
    /// `experimental-claude-tag-2026-10-21` in this header.
    public var betas: [AnthropicBetaParam]?

    public init(slack: BetaClaudeTagSlackChannelIdentifiersParam, settings: BetaClaudeTagSettingsCreateParam? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.slack = slack
        self.settings = settings
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case slack
        case settings
        case betas
    }
}
