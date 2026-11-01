// Transformed from `anthropic.types.beta.organization.beta_claude_tag_guest_policy_allow_param` (beta_claude_tag_guest_policy_allow_param.py).

import Foundation

/// Claude answers in the channel.
public struct BetaClaudeTagGuestPolicyAllowParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "allow") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
