// Transformed from `anthropic.types.beta.beta_fallback_info` (beta_fallback_info.py).

import Foundation

/// Identifies one hop of a fallback transition.
public struct BetaFallbackInfo: Codable, Hashable, Sendable {
    /// The model that will complete your prompt.
    ///
    /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    /// details and options.
    public var model: Model

    public init(model: Model) {
        self.model = model
    }

    enum CodingKeys: String, CodingKey {
        case model
    }
}
