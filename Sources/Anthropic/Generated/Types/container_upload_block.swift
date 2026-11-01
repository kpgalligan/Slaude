// Transformed from `anthropic.types.container_upload_block` (container_upload_block.py).

import Foundation

/// Response model for a file uploaded to the container.
public struct ContainerUploadBlock: Codable, Hashable, Sendable {
    public var fileID: String
    public var type: String

    public init(fileID: String, type: String = "container_upload") {
        self.fileID = fileID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case fileID = "file_id"
        case type
    }
}
