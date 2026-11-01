// Transformed from `anthropic.types.beta.organization.beta_claude_tag_settings` (beta_claude_tag_settings.py).

import Foundation

/// Claude Tag settings.
///
/// Without `include_inherited`, a setting that is null is not set on the settings level and is inherited. With it, `enabled` and `guest_policy` are never null, and `instructions`, `model` and `environment_id` are null when no settings level sets them.
public struct BetaClaudeTagSettings: Codable, Hashable, Sendable {
    /// Whether Claude is on. The nearest settings level that sets it decides.
    public var enabled: Bool?
    /// The environment Claude's sessions run in, starting with `env_`, or the
    /// identifier of a self-hosted runner pool, starting with `ccpool_`. The nearest
    /// settings level that sets it decides.
    public var environmentId: String?
    /// What Claude does in a channel while a Slack guest is in it.
    ///
    /// The nearest settings level that sets it decides.
    public var guestPolicy: BetaClaudeTagGuestPolicy?
    /// Instructions for Claude.
    ///
    /// Instructions add up: the text of every settings level that sets it is joined,
    /// broadest first.
    public var instructions: String?
    /// The model Claude uses: a model identifier or the name of a model line.
    ///
    /// The nearest settings level that sets it decides. When none does, Claude uses the
    /// product's default model.
    public var model: String?

    public init(enabled: Bool? = nil, environmentId: String? = nil, guestPolicy: BetaClaudeTagGuestPolicy? = nil, instructions: String? = nil, model: String? = nil) {
        self.enabled = enabled
        self.environmentId = environmentId
        self.guestPolicy = guestPolicy
        self.instructions = instructions
        self.model = model
    }

    enum CodingKeys: String, CodingKey {
        case enabled
        case environmentId = "environment_id"
        case guestPolicy = "guest_policy"
        case instructions
        case model
    }
}
