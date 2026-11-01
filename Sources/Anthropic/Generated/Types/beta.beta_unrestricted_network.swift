// Transformed from `anthropic.types.beta.beta_unrestricted_network` (beta_unrestricted_network.py).

import Foundation

/// Unrestricted network access.
public struct BetaUnrestrictedNetwork: Codable, Hashable, Sendable {
    /// Network policy type
    public var type: String

    public init(type: String = "unrestricted") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
