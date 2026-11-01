// Transformed from `anthropic.types.beta.beta_thinking_types` (beta_thinking_types.py).

import Foundation

/// Which `thinking.type` values the model accepts on requests.
///
/// Read each key on its own: for example, `enabled` can be false while `disabled` is true.
public struct BetaThinkingTypes: Codable, Hashable, Sendable {
    /// Whether the model accepts thinking with type 'adaptive' (the model decides
    /// whether and how much to think).
    public var adaptive: BetaCapabilitySupport
    /// Whether the model accepts thinking with type 'between_tools' (thinking turned
    /// off, and any short progress updates the model writes between tool calls come
    /// back as thinking blocks). False exactly when a request that sends it gets a 400
    /// from this model. A request that sends 'between_tools' can still be rejected for
    /// another reason, such as an effort level the model does not allow with thinking
    /// off.
    public var betweenTools: BetaCapabilitySupport
    /// Whether the model accepts thinking with type 'disabled' (thinking turned off).
    ///
    /// False exactly when a request that sends it gets a 400 from this model. True on a
    /// model that does not support thinking. A request that sends 'disabled' can still
    /// be rejected for another reason, such as an effort level the model does not allow
    /// with thinking off.
    public var disabled: BetaCapabilitySupport
    /// Whether the model accepts thinking with type 'enabled' (extended thinking with a
    /// caller-set `budget_tokens`).
    public var enabled: BetaCapabilitySupport

    public init(adaptive: BetaCapabilitySupport, betweenTools: BetaCapabilitySupport, disabled: BetaCapabilitySupport, enabled: BetaCapabilitySupport) {
        self.adaptive = adaptive
        self.betweenTools = betweenTools
        self.disabled = disabled
        self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case adaptive
        case betweenTools = "between_tools"
        case disabled
        case enabled
    }
}
