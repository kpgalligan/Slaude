// Transformed from `anthropic.types.beta.beta_environment_delete_response` (beta_environment_delete_response.py).

import Foundation

/// Response after deleting an environment.
public struct BetaEnvironmentDeleteResponse: Codable, Hashable, Sendable {
    /// Environment identifier
    public var id: String
    /// The type of response
    public var type: String

    public init(id: String, type: String = "environment_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
