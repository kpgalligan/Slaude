// Transformed from `anthropic.types.beta.organization.beta_claude_tag_guest_policy_restrict` (beta_claude_tag_guest_policy_restrict.py).

import Foundation

/// Claude does not answer in the channel.
public struct BetaClaudeTagGuestPolicyRestrict: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "restrict") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
