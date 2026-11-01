// Transformed from `anthropic.types.beta.organization.beta_claude_tag_guest_policy_restrict_param` (beta_claude_tag_guest_policy_restrict_param.py).

import Foundation

/// Claude does not answer in the channel.
public struct BetaClaudeTagGuestPolicyRestrictParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "restrict") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
