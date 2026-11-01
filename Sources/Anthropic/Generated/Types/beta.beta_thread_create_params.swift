// Transformed from `anthropic.types.beta.beta_thread_create_params` (beta_thread_create_params.py).

import Foundation

/// Start holding conversation state under this response's ``id``.
public struct BetaThreadCreateParams: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "create") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
