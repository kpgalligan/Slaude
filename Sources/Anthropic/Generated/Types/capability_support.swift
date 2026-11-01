// Transformed from `anthropic.types.capability_support` (capability_support.py).

import Foundation

/// Indicates whether a capability is supported.
public struct CapabilitySupport: Codable, Hashable, Sendable {
    /// Whether this capability is supported by the model.
    public var supported: Bool

    public init(supported: Bool) {
        self.supported = supported
    }

    enum CodingKeys: String, CodingKey {
        case supported
    }
}
