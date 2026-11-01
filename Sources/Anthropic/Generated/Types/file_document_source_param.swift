// Transformed from `anthropic.types.file_document_source_param` (file_document_source_param.py).

import Foundation

public struct FileDocumentSourceParam: Codable, Hashable, Sendable {
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
