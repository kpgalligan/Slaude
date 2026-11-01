// Transformed from `anthropic.types.file_document_source_param` (file_document_source_param.py).

import Foundation

public struct FileDocumentSourceParam: Codable, Hashable, Sendable {
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
