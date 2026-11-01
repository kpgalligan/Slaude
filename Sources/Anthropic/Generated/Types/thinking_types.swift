// Transformed from `anthropic.types.thinking_types` (thinking_types.py).

import Foundation

/// Which `thinking.type` values the model accepts on requests.
///
/// Read each key on its own: for example, `enabled` can be false while `disabled` is true.
public struct ThinkingTypes: Codable, Hashable, Sendable {
    /// Whether the model accepts thinking with type 'adaptive' (the model decides
    /// whether and how much to think).
    public var adaptive: CapabilitySupport
    /// Whether the model accepts thinking with type 'between_tools' (thinking turned
    /// off, and any short progress updates the model writes between tool calls come
    /// back as thinking blocks). False exactly when a request that sends it gets a 400
    /// from this model. A request that sends 'between_tools' can still be rejected for
    /// another reason, such as an effort level the model does not allow with thinking
    /// off.
    public var betweenTools: CapabilitySupport
    /// Whether the model accepts thinking with type 'disabled' (thinking turned off).
    ///
    /// False exactly when a request that sends it gets a 400 from this model. True on a
    /// model that does not support thinking. A request that sends 'disabled' can still
    /// be rejected for another reason, such as an effort level the model does not allow
    /// with thinking off.
    public var disabled: CapabilitySupport
    /// Whether the model accepts thinking with type 'enabled' (extended thinking with a
    /// caller-set `budget_tokens`).
    public var enabled: CapabilitySupport

    public init(adaptive: CapabilitySupport, betweenTools: CapabilitySupport, disabled: CapabilitySupport, enabled: CapabilitySupport) {
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
