// Transformed from `anthropic.types.beta.organization.beta_claude_tag_slack_default_setting_source` (beta_claude_tag_slack_default_setting_source.py).

import Foundation

/// The value comes from the organization's Slack defaults, which have no identifier.
public struct BetaClaudeTagSlackDefaultSettingSource: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "slack_default") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
