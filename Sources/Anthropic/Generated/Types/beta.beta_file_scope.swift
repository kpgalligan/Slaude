// Transformed from `anthropic.types.beta.beta_file_scope` (beta_file_scope.py).

import Foundation

public struct BetaFileScope: Codable, Hashable, Sendable {
    /// The ID of the scoping resource (e.g., the session ID).
    public var id: String
    /// The type of scope (e.g., `"session"`).
    public var type: String

    public init(id: String, type: String = "session") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
