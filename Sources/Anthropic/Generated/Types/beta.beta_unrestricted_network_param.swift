// Transformed from `anthropic.types.beta.beta_unrestricted_network_param` (beta_unrestricted_network_param.py).

import Foundation

/// Unrestricted network access.
public struct BetaUnrestrictedNetworkParam: Codable, Hashable, Sendable {
    /// Network policy type
    public var type: String

    public init(type: String = "unrestricted") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
