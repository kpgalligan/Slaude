// Transformed from `anthropic.types.beta.beta_file_image_source_param` (beta_file_image_source_param.py).

import Foundation

public struct BetaFileImageSourceParam: Codable, Hashable, Sendable {
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
