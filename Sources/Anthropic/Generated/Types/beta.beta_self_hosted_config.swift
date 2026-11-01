// Transformed from `anthropic.types.beta.beta_self_hosted_config` (beta_self_hosted_config.py).

import Foundation

/// Configuration for self-hosted environments.
public struct BetaSelfHostedConfig: Codable, Hashable, Sendable {
    /// Environment type
    public var type: String

    public init(type: String = "self_hosted") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
