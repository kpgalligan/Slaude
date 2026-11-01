// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_file_rubric` (beta_managed_agents_file_rubric.py).

import Foundation

/// Rubric referenced by a file uploaded via the Files API.
public struct BetaManagedAgentsFileRubric: Codable, Hashable, Sendable {
    /// ID of the rubric file.
    public var fileId: String
    public var type: String

    public init(fileId: String, type: String = "file") {
        self.fileId = fileId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case type
    }
}
