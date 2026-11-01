// Transformed from `anthropic.types.beta.beta_context_management_capability` (beta_context_management_capability.py).

import Foundation

/// Context management capability details.
public struct BetaContextManagementCapability: Codable, Hashable, Sendable {
    /// Whether the clear_thinking_20251015 strategy is supported.
    public var clearThinking20251015: BetaCapabilitySupport?
    /// Whether the clear_tool_uses_20250919 strategy is supported.
    public var clearToolUses20250919: BetaCapabilitySupport?
    /// Whether the compact_20260112 strategy is supported.
    public var compact20260112: BetaCapabilitySupport?
    /// Whether this capability is supported by the model.
    public var supported: Bool

    public init(clearThinking20251015: BetaCapabilitySupport? = nil, clearToolUses20250919: BetaCapabilitySupport? = nil, compact20260112: BetaCapabilitySupport? = nil, supported: Bool) {
        self.clearThinking20251015 = clearThinking20251015
        self.clearToolUses20250919 = clearToolUses20250919
        self.compact20260112 = compact20260112
        self.supported = supported
    }

    enum CodingKeys: String, CodingKey {
        case clearThinking20251015 = "clear_thinking_20251015"
        case clearToolUses20250919 = "clear_tool_uses_20250919"
        case compact20260112 = "compact_20260112"
        case supported
    }
}
