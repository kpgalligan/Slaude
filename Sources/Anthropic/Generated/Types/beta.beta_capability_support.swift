// Transformed from `anthropic.types.beta.beta_capability_support` (beta_capability_support.py).

import Foundation

/// Indicates whether a capability is supported.
public struct BetaCapabilitySupport: Codable, Hashable, Sendable {
    /// Whether this capability is supported by the model.
    public var supported: Bool

    public init(supported: Bool) {
        self.supported = supported
    }

    enum CodingKeys: String, CodingKey {
        case supported
    }
}
