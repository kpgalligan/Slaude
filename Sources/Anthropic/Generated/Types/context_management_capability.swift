// Transformed from `anthropic.types.context_management_capability` (context_management_capability.py).

import Foundation

/// Context management capability details.
public struct ContextManagementCapability: Codable, Hashable, Sendable {
    /// Whether the clear_thinking_20251015 strategy is supported.
    public var clearThinking20251015: CapabilitySupport?
    /// Whether the clear_tool_uses_20250919 strategy is supported.
    public var clearToolUses20250919: CapabilitySupport?
    /// Whether the compact_20260112 strategy is supported.
    public var compact20260112: CapabilitySupport?
    /// Whether this capability is supported by the model.
    public var supported: Bool

    public init(clearThinking20251015: CapabilitySupport? = nil, clearToolUses20250919: CapabilitySupport? = nil, compact20260112: CapabilitySupport? = nil, supported: Bool) {
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
