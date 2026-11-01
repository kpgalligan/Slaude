// Transformed from `anthropic.types.beta.organization.beta_claude_tag_guest_policy_channel_only_param` (beta_claude_tag_guest_policy_channel_only_param.py).

import Foundation

/// Claude answers with only the Bundles attached to the channel itself.
public struct BetaClaudeTagGuestPolicyChannelOnlyParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "channel_only") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
