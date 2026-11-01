// Transformed from `anthropic.types.beta.beta_container_upload_block` (beta_container_upload_block.py).

import Foundation

/// Response model for a file uploaded to the container.
public struct BetaContainerUploadBlock: Codable, Hashable, Sendable {
    public var fileId: String
    public var type: String

    public init(fileId: String, type: String = "container_upload") {
        self.fileId = fileId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case type
    }
}
