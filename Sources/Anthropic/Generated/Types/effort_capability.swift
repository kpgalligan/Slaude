// Transformed from `anthropic.types.effort_capability` (effort_capability.py).

import Foundation

/// Effort (reasoning_effort) capability details.
public struct EffortCapability: Codable, Hashable, Sendable {
    /// Whether the model supports high effort level.
    public var high: CapabilitySupport
    /// Whether the model supports low effort level.
    public var low: CapabilitySupport
    /// Whether the model supports max effort level.
    public var max: CapabilitySupport
    /// Whether the model supports medium effort level.
    public var medium: CapabilitySupport
    /// Whether this capability is supported by the model.
    public var supported: Bool
    /// Whether the model supports xhigh effort level.
    public var xhigh: CapabilitySupport?

    public init(high: CapabilitySupport, low: CapabilitySupport, max: CapabilitySupport, medium: CapabilitySupport, supported: Bool, xhigh: CapabilitySupport? = nil) {
        self.high = high
        self.low = low
        self.max = max
        self.medium = medium
        self.supported = supported
        self.xhigh = xhigh
    }

    enum CodingKeys: String, CodingKey {
        case high
        case low
        case max
        case medium
        case supported
        case xhigh
    }
}
