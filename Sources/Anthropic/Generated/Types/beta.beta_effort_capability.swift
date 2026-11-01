// Transformed from `anthropic.types.beta.beta_effort_capability` (beta_effort_capability.py).

import Foundation

/// Effort (reasoning_effort) capability details.
public struct BetaEffortCapability: Codable, Hashable, Sendable {
    /// Whether the model supports high effort level.
    public var high: BetaCapabilitySupport
    /// Whether the model supports low effort level.
    public var low: BetaCapabilitySupport
    /// Whether the model supports max effort level.
    public var max: BetaCapabilitySupport
    /// Whether the model supports medium effort level.
    public var medium: BetaCapabilitySupport
    /// Whether this capability is supported by the model.
    public var supported: Bool
    /// Whether the model supports xhigh effort level.
    public var xhigh: BetaCapabilitySupport?

    public init(high: BetaCapabilitySupport, low: BetaCapabilitySupport, max: BetaCapabilitySupport, medium: BetaCapabilitySupport, supported: Bool, xhigh: BetaCapabilitySupport? = nil) {
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
