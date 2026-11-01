// Transformed from `anthropic.types.beta.beta_file_document_source_param` (beta_file_document_source_param.py).

import Foundation

public struct BetaFileDocumentSourceParam: Codable, Hashable, Sendable {
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
