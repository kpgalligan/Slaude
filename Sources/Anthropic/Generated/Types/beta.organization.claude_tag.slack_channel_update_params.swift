// Transformed from `anthropic.types.beta.organization.claude_tag.slack_channel_update_params` (slack_channel_update_params.py).

import Foundation

public struct SlackChannelUpdateParams: Codable, Hashable, Sendable {
    /// The settings to change.
    public var settings: BetaClaudeTagSettingsUpdateParam
    /// This endpoint is in beta: requests must send
    /// `experimental-claude-tag-2026-10-21` in this header.
    public var betas: [AnthropicBetaParam]?

    public init(settings: BetaClaudeTagSettingsUpdateParam, betas: [AnthropicBetaParam]? = nil) {
        self.settings = settings
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case settings
        case betas
    }
}
