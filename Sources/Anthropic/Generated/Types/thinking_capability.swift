// Transformed from `anthropic.types.thinking_capability` (thinking_capability.py).

import Foundation

/// Thinking capability details.
public struct ThinkingCapability: Codable, Hashable, Sendable {
    /// Whether this capability is supported by the model.
    public var supported: Bool
    /// Supported thinking type configurations.
    public var types: ThinkingTypes

    public init(supported: Bool, types: ThinkingTypes) {
        self.supported = supported
        self.types = types
    }

    enum CodingKeys: String, CodingKey {
        case supported
        case types
    }
}
