// Transformed from `anthropic.types.beta.beta_container_upload_block_param` (beta_container_upload_block_param.py).

import Foundation

/// A content block that represents a file to be uploaded to the container
/// Files uploaded via this block will be available in the container's input directory.
public struct BetaContainerUploadBlockParam: Codable, Hashable, Sendable {
    public var fileID: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??

    public init(fileID: String, type: String = "container_upload", cacheControl: BetaCacheControlEphemeralParam?? = nil) {
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
