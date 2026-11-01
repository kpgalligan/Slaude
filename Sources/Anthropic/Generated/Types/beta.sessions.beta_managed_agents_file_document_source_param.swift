// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_file_document_source_param` (beta_managed_agents_file_document_source_param.py).

import Foundation

/// Document referenced by file ID.
public struct BetaManagedAgentsFileDocumentSourceParam: Codable, Hashable, Sendable {
    /// ID of a previously uploaded file.
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
