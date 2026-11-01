// Transformed from `anthropic.types.beta.organization.beta_claude_tag_default_setting_source` (beta_claude_tag_default_setting_source.py).

import Foundation

/// No settings level sets a value, and the built-in default applies.
public struct BetaClaudeTagDefaultSettingSource: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "default") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
