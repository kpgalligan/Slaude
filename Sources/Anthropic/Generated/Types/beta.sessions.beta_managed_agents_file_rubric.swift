// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_file_rubric` (beta_managed_agents_file_rubric.py).

import Foundation

/// Rubric referenced by a file uploaded via the Files API.
public struct BetaManagedAgentsFileRubric: Codable, Hashable, Sendable {
    /// ID of the rubric file.
    public var fileID: String
    public var type: String

    public init(fileID: String, type: String = "file") {
        self.fileID = fileID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case fileID = "file_id"
        case type
    }
}
