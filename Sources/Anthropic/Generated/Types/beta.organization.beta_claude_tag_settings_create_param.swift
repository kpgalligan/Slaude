// Transformed from `anthropic.types.beta.organization.beta_claude_tag_settings_create_param` (beta_claude_tag_settings_create_param.py).

import Foundation

/// The settings in a request that sets a Slack channel up.
///
/// A setting left out is not set. A setting sent as null is cleared.
public struct BetaClaudeTagSettingsCreateParam: Codable, Hashable, Sendable {
    /// Whether Claude is on.
    ///
    /// `true` on a channel turns Claude on in it even when its workspace stores
    /// `false`. Null clears it.
    public var enabled: Bool??
    /// The environment Claude's sessions run in: the identifier of an active
    /// environment of the organization, starting with `env_`. Null clears it.
    public var environmentID: String??
    /// What Claude does in a channel while a Slack guest is in it. Null clears it.
    public var guestPolicy: BetaClaudeTagGuestPolicyParam??
    /// Instructions for Claude, up to 8,192 characters after leading and trailing white
    /// space is trimmed. Null or blank text clears them.
    public var instructions: String??
    /// The model Claude uses: the identifier of a model, or the name of a model line,
    /// that the organization is entitled to for Claude Tag. Null clears it.
    public var model: String??

    public init(enabled: Bool?? = nil, environmentID: String?? = nil, guestPolicy: BetaClaudeTagGuestPolicyParam?? = nil, instructions: String?? = nil, model: String?? = nil) {
        self.enabled = enabled
        self.environmentID = environmentID
        self.guestPolicy = guestPolicy
        self.instructions = instructions
        self.model = model
    }

    enum CodingKeys: String, CodingKey {
        case enabled
        case environmentID = "environment_id"
        case guestPolicy = "guest_policy"
        case instructions
        case model
    }
}
