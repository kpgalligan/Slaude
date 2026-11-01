// Transformed from `anthropic.types.container_upload_block_param` (container_upload_block_param.py).

import Foundation

/// A content block that represents a file to be uploaded to the container
/// Files uploaded via this block will be available in the container's input directory.
public struct ContainerUploadBlockParam: Codable, Hashable, Sendable {
    public var fileID: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??

    public init(fileID: String, type: String = "container_upload", cacheControl: CacheControlEphemeralParam?? = nil) {
        self.fileID = fileID
        self.type = type
        self.cacheControl = cacheControl
    }

    enum CodingKeys: String, CodingKey {
        case fileID = "file_id"
        case type
        case cacheControl = "cache_control"
    }
}
