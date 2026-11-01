// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_file_image_source_param` (beta_managed_agents_file_image_source_param.py).

import Foundation

/// Image referenced by file ID.
public struct BetaManagedAgentsFileImageSourceParam: Codable, Hashable, Sendable {
    /// ID of a previously uploaded file.
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
