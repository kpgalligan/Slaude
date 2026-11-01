// Transformed from `anthropic.types.beta.organization.beta_claude_tag_setting_sources` (beta_claude_tag_setting_sources.py).

import Foundation

/// For each setting, the settings level its value in `settings` comes from.
///
/// Without `include_inherited`, a setting the channel or workspace stores has a source that names the channel or workspace itself, and one it does not store has null, or an empty list for `instructions`. With `include_inherited=true` no member is null: a value that no settings level sets has the source `default`.
public struct BetaClaudeTagSettingSources: Codable, Hashable, Sendable {
    /// The settings level `enabled` comes from.
    public var enabled: BetaClaudeTagSettingSource?
    /// The settings level `environment_id` comes from.
    public var environmentId: BetaClaudeTagSettingSource?
    /// The settings level `guest_policy` comes from.
    public var guestPolicy: BetaClaudeTagSettingSource?
    /// Every settings level that contributes text to `instructions`, broadest first, in
    /// the order their text is joined. Empty when none does.
    public var instructions: [BetaClaudeTagSettingSource]
    /// The settings level `model` comes from.
    public var model: BetaClaudeTagSettingSource?

    public init(enabled: BetaClaudeTagSettingSource? = nil, environmentId: BetaClaudeTagSettingSource? = nil, guestPolicy: BetaClaudeTagSettingSource? = nil, instructions: [BetaClaudeTagSettingSource], model: BetaClaudeTagSettingSource? = nil) {
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
