// Transformed from `anthropic.types.beta.beta_fallback_info_param` (beta_fallback_info_param.py).

import Foundation

/// Identifies one hop of a fallback transition.
public struct BetaFallbackInfoParam: Codable, Hashable, Sendable {
    /// The model that will complete your prompt.
    ///
    /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    /// details and options.
    public var model: ModelParam

    public init(model: ModelParam) {
        self.model = model
    }

    enum CodingKeys: String, CodingKey {
        case model
    }
}
