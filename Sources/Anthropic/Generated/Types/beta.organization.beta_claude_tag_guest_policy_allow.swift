// Transformed from `anthropic.types.beta.organization.beta_claude_tag_guest_policy_allow` (beta_claude_tag_guest_policy_allow.py).

import Foundation

/// Claude answers in the channel.
public struct BetaClaudeTagGuestPolicyAllow: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "allow") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
