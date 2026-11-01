// Transformed from `anthropic.types.beta.environments.beta_session_work_data` (beta_session_work_data.py).

import Foundation

/// Work data for session work items.
///
/// This resource type is used when work represents a session that needs to be executed
/// in a self-hosted environment.
public struct BetaSessionWorkData: Codable, Hashable, Sendable {
    /// Session identifier (e.g., 'session\__...')
    public var id: String
    /// Type of work data
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
