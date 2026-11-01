// Transformed from `anthropic.types.beta.beta_thinking_capability` (beta_thinking_capability.py).

import Foundation

/// Thinking capability details.
public struct BetaThinkingCapability: Codable, Hashable, Sendable {
    /// Whether this capability is supported by the model.
    public var supported: Bool
    /// Supported thinking type configurations.
    public var types: BetaThinkingTypes

    public init(supported: Bool, types: BetaThinkingTypes) {
        self.supported = supported
        self.types = types
    }

    enum CodingKeys: String, CodingKey {
        case supported
        case types
    }
}
