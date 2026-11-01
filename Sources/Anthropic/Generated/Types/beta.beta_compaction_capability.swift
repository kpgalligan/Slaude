// Transformed from `anthropic.types.beta.beta_compaction_capability` (beta_compaction_capability.py).

import Foundation

/// Compaction capability details: whether the model accepts the top-level
/// `compaction` request parameter, with one entry per supported
/// `compaction.type` value.
public struct BetaCompactionCapability: Codable, Hashable, Sendable {
    /// Whether the summarize compaction type is supported.
    public var summarize: BetaCapabilitySupport
    /// Whether this capability is supported by the model.
    public var supported: Bool

    public init(summarize: BetaCapabilitySupport, supported: Bool) {
        self.summarize = summarize
        self.supported = supported
    }

    enum CodingKeys: String, CodingKey {
        case summarize
        case supported
    }
}
