// Transformed from `anthropic.types.beta.beta_self_hosted_config_params` (beta_self_hosted_config_params.py).

import Foundation

/// Request params for `self_hosted` environment configuration.
public struct BetaSelfHostedConfigParams: Codable, Hashable, Sendable {
    /// Environment type
    public var type: String

    public init(type: String = "self_hosted") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
